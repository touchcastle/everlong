import 'package:flutter/material.dart';
import 'package:everlong/services/piano.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/staff.dart';
import 'package:everlong/services/device_db.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/midi.dart';

/// Type of reorder list and on-screen list.
enum ReorderType {
  /// When new master was selected.
  master,

  /// When disconnected device becomes connected.
  connected,

  /// When connected device become disconnected.
  disconnected,
}

class Classroom extends ChangeNotifier {
  /// Store holding keys for purpose of clearing.
  List<int> holdingKeys = [];
  bool isHolding = false;

  /// To store host ID when there is a active host.
  String masterID = kNoMaster;
  String masterName = kNoMaster;

  /// Set to true when user ping all device for display ping animation.
  bool isPingAll = false;

  /// List of all discovered bluetooth device.
  List<BLEDevice> bluetoothDevices = [];

  /// Import classes
  DeviceDatabase _db;
  ListAnimation _ui;

  /// Set to true when resetting all keys for display progress indicator.
  bool isResetting = false;

  /// Set to true when clear holding keys for display progress indicator.
  bool isClearing = false;

  /// To switch between music notation or Device/Member list on mobile device.
  bool showList = true;

  /// To switch recorder / share view display.
  bool showRecorder = false;

  /// Flag for first start local session before any set/reset master device.
  /// In case of fresh start, first connected device will become master.
  bool freshStart = true;

  ///For pressing notes and chord(By master device or room host) on screen.
  Piano piano = Piano();

  /// Constructor
  Classroom(this._db, this._ui);

  ///Init class parameter
  void resetClass() {
    holdingKeys.clear();
    isHolding = false;
    piano.resetDisplay();
    Staff.resetDisplay();
  }

  ///Check parameters and conditions before actual send MIDI bluetooth
  ///
  ///Called from master bluetooth device model.
  Future prepareBeforeLocalBroadcast(Uint8List data) async {
    bool _withSound = false;
    bool _withLight = false;
    bool _withDelay = false;

    //Whether to send any signal or not.
    bool _isListening() => Setting.appListenMode != ListenMode.off;

    //To send both light and sound.
    bool _isListenAll() => Setting.appListenMode == ListenMode.on;

    //To send only sound.
    bool _isBlind() => Setting.appListenMode == ListenMode.onBlind;

    //To send only light
    bool _isMute() => Setting.appListenMode == ListenMode.onMute;

    //Is this key already on holding? Don't need to send it again.
    bool _holdingDup() => holdingKeys.contains(data[kKeyPos]);

    if (_isListening() && !_holdingDup()) {
      //Prepare parameters.
      if (!_isBlind()) _withLight = true;
      if (!_isMute()) _withSound = true;
      if (_isListenAll()) _withDelay = true;

      //Send midi to target bluetooth device(s).
      sendLocal(
        data,
        withSound: _withSound,
        withLight: _withLight,
        withDelay: _withDelay,
      );
    }
  }

  /// Generate MIDI output message and send to out to connected device with
  /// condition depends on [Setting.appListenMode]
  /// and [_delay] between each device.
  /// for [ListenMode.off] -> send nothing.
  /// for [ListenMode.on] -> send both sound and light.
  /// for [ListenMode.onMute] -> send light only.
  /// for [ListenMode.onBlind] -> send sound only.
  ///
  /// Called from:
  /// 1. master bluetooth device model(via [prepareBeforeLocalBroadcast()])
  /// 2. Online session message listener.
  /// 3. Record file playback.
  Future sendLocal(
    Uint8List data, {
    required bool withSound,
    required bool withLight,
    bool withDelay = false,
    bool withStaff = true,
    bool withMaster = false,
  }) async {
    //To display note on staff
    if (withStaff) staffDisplay(data);

    //Only in normal mode or only note on in holding mode
    if ((!isHolding || (isHolding && data[kSwitchPos] == kNoteOn))) {
      //If in holding mode, store holding key in list for release later.
      if (isHolding) holdingKeys.add(data[kKeyPos]);

      //Send sound/light if there is child device or force send to master also.
      if (countChild() > 0 || withMaster) {
        int _delay = 1;

        // If there is several child devices, add delay between each device send
        if (countChild() > 0)
          _delay = Setting.noteDelayMillisec ~/ countChild();

        // Send light/sound to target device(s).
        for (BLEDevice _device
            in bluetoothDevices.where((d) => d.isConnected())) {
          if (!_device.isMaster || withMaster) {
            //LIGHT
            if (withLight)
              _device.writeLightMessage(data[kKeyPos], data[kSwitchPos]);

            //Little delay between light and sound for bluetooth stability
            if (withDelay) await _wait(_delay);

            //SOUND
            if (withSound) _device.write(message: data);

            //Delay between each device.
            await _wait(_delay);
          }
        }
      }
    }
  }

  /// Update staff display and playing notes/chord.
  void staffDisplay(Uint8List data) async {
    //For playing notes and chord.
    if (data[kSwitchPos] == kNoteOn) {
      this.piano.addPressing(data[kKeyPos]);
    } else if (data[kSwitchPos] == kNoteOff) {
      this.piano.removePressing(data[kKeyPos]);
    }

    //For staff display (music notation).
    Staff.updateStaff(data[kKeyPos], data[kSwitchPos]);

    notifyListeners();
  }

  /// Delay
  Future _wait(int milliseconds) async =>
      await Future.delayed(Duration(milliseconds: milliseconds));

  /// To count connected children devices.
  int countChild() => bluetoothDevices
      .where((d) => d.isConnected() && !d.isMaster)
      .toList()
      .length;

  /// When connected children device's more than [_count] devices,
  /// increase [Setting.noteDelayMillisec] for [_delay] milliseconds for each
  /// device after [_count].
  void devicesIncrement() {
    final int _count = 5;
    final int _delay = 10;
    if (countChild() > _count)
      Setting.noteDelayMillisec += ((countChild() - _count) * _delay);
  }

  /// After host start hold. every pressed keys will be kept in [holdingKeys].
  ///
  /// When host release hold.
  /// send light OFF message to every keys in [holdingKeys] then clear.
  Future releaseHold() async {
    isClearing = true;
    notifyListeners();
    for (BLEDevice _device in bluetoothDevices.where((d) => d.isConnected())) {
      for (int _key in holdingKeys) {
        await _device.writeLightMessage(_key, kLightOff);
        await Future.delayed(Duration(milliseconds: kNoteDelayMillisec));
      }
    }
    holdingKeys.clear();
    isClearing = false;
    notifyListeners();
  }

  /// Keep MIDI device awake by send MIDI message [kAwakeMIDI]
  /// for every [kKeepAwakeDuration].
  ///
  /// 1.0.0: send sound message with pressure = 1.
  void keepAwake() {
    Timer.periodic(kKeepAwakeDuration, (Timer t) async {
      for (BLEDevice _device
          in bluetoothDevices.where((d) => d.isConnected())) {
        _device.write(message: kAwakeMIDI);
        // await _device.write(message: kAwakeMIDI);
        await _wait(1000);
      }
    });
  }

  /// To check is there any connected device.
  bool anyConnected() =>
      bluetoothDevices.where((d) => d.isConnected()).toList().length > 0
          ? true
          : false;

  /// For device ping. app will display beacon lights and play
  /// [kMidCSound] for [kNotifyTimes] times on target device .
  Future pingDevice(BLEDevice device) async {
    if (!device.isOnPing) {
      device.togglePing();
      notifyListeners();
      _beaconLight(device);
      for (int _i = 1; _i <= kNotifyTimes; _i++) {
        device.write(message: kMidCSound); //Play note
        await Future.delayed(kNotifyDuration);
      }
      device.togglePing();
      notifyListeners();
    }
  }

  /// Light beacon sender.
  void _beaconLight(BLEDevice device) async {
    for (int _lightKey in kIdentLight) {
      device.writeLightMessage(_lightKey, kNoteOn);
      await Future.delayed(kNotifyLightDuration); //Keep light on fo sometime
      device.writeLightMessage(_lightKey, kNoteOff);
    }
  }

  /// Ping all connected devices.
  void pingAllDevices() async {
    if (!isPingAll) {
      isPingAll = true;
      notifyListeners();

      /// For bluetooth stability, Delay between each device.
      for (BLEDevice device in bluetoothDevices.where((d) => d.isConnected())) {
        pingDevice(device);
        await _wait(Setting.noteDelayMillisec);
      }
      await Future.delayed(kNotifyDuration * kNotifyTimes);
      isPingAll = false;
      notifyListeners();
    }
  }

  /// Let [device] become master or cancel.
  Future setMaster(BLEDevice device) async {
    freshStart = false;
    if (isHolding) triggerHold(false);

    if (this.masterID == device.id()) {
      /// Cancel current master
      this.masterID = kNoMaster;
      this.masterName = kNoMaster;
      await device.toggleMaster(false);
      notifyListeners();
    } else {
      /// Cancel old master device first.
      int _i = bluetoothDevices.indexWhere((d) => d.isMaster);
      if (_i >= 0) await bluetoothDevices[_i].toggleMaster(false);

      await device.toggleMaster(true);
      this.masterID = device.id();
      this.masterName = device.displayName;
      notifyListeners();
      sortList(ReorderType.master, device.id());
    }
  }

  void masterDisconnected() {
    freshStart = false;
    this.masterID = kNoMaster;
    this.masterName = kNoMaster;
    notifyListeners();
  }

  void masterReconnected({required String id, required String name}) {
    freshStart = false;
    this.masterID = id;
    this.masterName = name;
    notifyListeners();
  }

  /// To sort device list after some user actions.
  /// - [ReorderType.master] : Change host -> swap host to first index.
  /// - [ReorderType.connected] : new connected ->
  /// swap device to last of connected device.
  /// - [ReorderType.disconnected] : new disconnected ->
  /// swap device to first of disconnected device.
  void sortList(ReorderType type, String id) async {
    // Reorder only in local mode.
    // Online devices list use ListView.builder instead of AnimatedList.
    if (Setting.sessionMode == SessionMode.offline) {
      switch (type) {
        case ReorderType.master:
          _getIndexFromID(id) == 0 ? notifyListeners() : _reorderList(id, 0);
          break;
        case ReorderType.connected:
          int _firstOfDisconnected =
              bluetoothDevices.indexWhere((d) => !d.isConnected());
          int _itself = _getIndexFromID(id);
          if (bluetoothDevices[_itself].isMaster && _itself != 0) {
            _reorderList(id, 0);
          } else if (_itself > _firstOfDisconnected &&
              _firstOfDisconnected >= 0) {
            _reorderList(id, _firstOfDisconnected);
          }
          break;
        case ReorderType.disconnected:
          int _lastOfConnected =
              bluetoothDevices.lastIndexWhere((d) => d.isConnected());
          int _current = _getIndexFromID(id);
          if (_current < _lastOfConnected) _reorderList(id, _lastOfConnected);
          break;
      }
    }
  }

  /// Reorder [bluetoothDevices] and animate list on screen via [_ui].
  void _reorderList(String id, int insertIndexAfterRemove) async {
    ///Remove
    int _removeIndex = _getIndexFromID(id);
    final BLEDevice device = bluetoothDevices[_removeIndex];
    bluetoothDevices.removeAt(_removeIndex);
    _ui.listViewRemove(_removeIndex, device);
    await Future.delayed(
        Duration(milliseconds: kListAnimateDuration + kBeforeNextAnimate));

    ///Insert
    bluetoothDevices.insert(insertIndexAfterRemove, device);
    _ui.listViewInsert(insertIndexAfterRemove);
  }

  /// Hold mode.
  // void toggleHold(){
  //
  //   notifyListeners();
  // }
  void triggerHold(bool hold) async {
    if (!hold && isHolding) {
      await releaseHold();
      resetDisplay();
    }
    isHolding = hold;
    notifyListeners();
  }

  /// Force turn off all key's light of every children devices 1 by 1
  /// with delay between each keys.
  Future resetKeyLight() async {
    this.isResetting = true;
    notifyListeners();
    for (BLEDevice _d
        in bluetoothDevices.where((d) => d.isConnected() && !d.isMaster)) {
      // await _d.lightOffOnlyMonitoredOnKeys();
      await _d.lightOffAllKeys();
    }
    this.isResetting = false;
    notifyListeners();
  }

  /// To switch editable text field of device's name.
  void toggleNameEditing(BLEDevice device) {
    device.isEditingName = !device.isEditingName;
    notifyListeners();
  }

  /// Update user's edited device's name to database and [bluetoothDevices].
  Future updateDeviceDisplayName({required String id, String? name}) async {
    if (name != null) {
      await _db.updateName(id: id, name: name);
      bluetoothDevices[_getIndexFromID(id)].displayName = name;
      if (masterID == id) masterName = name;
      notifyListeners();
    }
  }

  /// Return index of device's id.
  int _getIndexFromID(String id) =>
      bluetoothDevices.indexWhere((d) => d.id() == id);

  void toggleListDisplay({bool? forceShow}) {
    if (forceShow != null) {
      showList = forceShow;
    } else {
      showList = !showList;
    }

    notifyListeners();
  }

  void toggleRecordManagerDisplay() {
    if (!showRecorder) toggleListDisplay(forceShow: true);
    showRecorder = !showRecorder;
    // if (showRecorder) {
    //   localRecorderController.forward();
    // } else {
    //   localRecorderController.reverse();
    // }
    notifyListeners();
  }

  void subscribeAllConnectedDevice() {
    for (BLEDevice _device
        in bluetoothDevices.where((d) => d.isConnected() && !d.isListening)) {
      _device.listenTo();
    }
  }

  Future cancelDeviceSubscribe() async {
    for (BLEDevice _device
        in bluetoothDevices.where((d) => d.isConnected() && d.isListening)) {
      await _device.cancelListen();
    }
  }

  Future cancelAllMaster() async {
    for (BLEDevice _device
        in bluetoothDevices.where((d) => d.isConnected() && d.isMaster)) {
      await setMaster(_device);
    }
  }

  ///Close all expanding device list.
  void closeAllExpanding() {
    for (int i = 0; i < bluetoothDevices.length; i++) {
      bluetoothDevices[i].isExpanding = false;
    }
  }

  /// To reset notes on staff and virtual piano.
  void resetDisplay({bool onlineRelease = false}) {
    Staff.resetDisplay();
    piano.resetDisplay();
    notifyListeners();
  }

  ///To display correct setting's button color since there are other way
  ///to enter setting screen beside of setting button itself.
  bool showingSetting = false;

  void toggleShowingSetting(bool show) {
    showingSetting = show;
    notifyListeners();
  }
}
