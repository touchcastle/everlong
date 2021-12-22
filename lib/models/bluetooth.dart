import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'dart:typed_data';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/piano.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/midi.dart';

enum ConnectionState { connected, disconnected, working }
enum ConnectionResult { success, failed, timeout }

///Main device list for the app.
class BLEDevice extends ChangeNotifier {
  Classroom _classroom;
  Online _online;
  Recorder _recorder;

  /// Main model for device.
  BluetoothDevice device;

  /// To store MIDI service of bluetooth device.
  BluetoothService? service;

  /// To store MIDI characteristic of bluetooth device for listening to
  /// incoming MIDI message and send out MIDI message to device.
  BluetoothCharacteristic? characteristic;

  /// Set to true when connecting for display progress indicator.
  bool isConnecting;

  /// Set to true when user ping device for display ping animation.
  bool isOnPing;

  /// When device is master, app will listen to device MIDI message.
  bool isMaster;

  /// To store Expanding widget state for purpose of change index and re-connect.
  bool isExpanding;

  /// Each child device can have different type of listening [ListenMode].
  // ListenMode isListening;

  /// User's custom device name. Sync with database.
  String displayName;

  /// Subscription to device connection state.
  StreamSubscription<BluetoothDeviceState>? stateSubscribe;

  /// Subscription to device incoming MIDI message. Can be cancel when user
  /// swap host to other device or cancel host.
  StreamSubscription<List<int>>? inputSubscribe;
  bool isListening = false;

  /// Set to true when user editing device's name. Use for display editable text
  /// field.
  bool isEditingName;

  /// keep update and store device's connection state in this parameter.
  BluetoothDeviceState lastKnownState;

  /// was connected before.
  bool onceConnected = false;

  /// intentionally disconnect.
  bool userDisconnect = false;

  Piano piano = Piano();

  BLEDevice(this._classroom, this._online, this._recorder,
      {required this.device,
      this.isConnecting = false,
      this.isOnPing = false,
      this.isMaster = false,
      this.isEditingName = false,
      this.isExpanding = false,
      // this.isListening = ListenMode.onMute,
      required this.displayName,
      this.lastKnownState = BluetoothDeviceState.disconnected});

  /// Keep listen to device's connection state.
  /// Trigger function when state changes.
  void initDevice() {
    this.stateSubscribe = this.device.state.listen(null);
    stateSubscribe?.onData((state) {
      if (state == BluetoothDeviceState.connected) {
        this._onConnected();
      } else if (state == BluetoothDeviceState.disconnected) {
        this._onDisconnected();
      }
    });
  }

  /// Check device's connection state via [lastKnownState].
  bool isConnected() =>
      this.lastKnownState == BluetoothDeviceState.connected ? true : false;

  /// Device's String ID (UUID for iOS and MAC Address for Android).
  String id() => this.device.id.id;

  /// Connect device.
  Future<ConnectionResult> connect(Duration timeout) async {
    ConnectionResult _isSuccess = ConnectionResult.success;
    try {
      print('start connection');
      await this.device.connect().timeout(timeout);
    } on TimeoutException {
      print('timeout');
      this.disconnect();
      _isSuccess = ConnectionResult.timeout;
    } on Exception catch (e) {
      print('exception: $e');
      _isSuccess = ConnectionResult.failed;
    }
    return _isSuccess;
  }

  void initPiano() => this.piano.keyList = this.piano.generateKeysList();

  /// Connected Event(Device stage) handler
  void _onConnected() async {
    this.lastKnownState = BluetoothDeviceState.connected;
    this.onceConnected = true;
    this.initPiano();
    // if (Platform.isAndroid) this._requestMTU();
    await this._getMIDIService();
    await this._getMIDICharacteristic();
    if (Setting.sessionMode == SessionMode.offline && this.isMaster) {
      _classroom.masterReconnected(id: this.id(), name: this.displayName);
    }

    bool _isLocalMaster() =>
        Setting.sessionMode == SessionMode.offline && this.isMaster;
    bool _isOnlineSpeaker() =>
        Setting.sessionMode == SessionMode.online &&
        (_online.isRoomHost || _online.imListenable);

    if (_isLocalMaster() || _isOnlineSpeaker()) this.listenTo();

    _classroom.sortList(ReorderType.connected, this.id());
    if (_isPopPiano()) {
      // await Future.delayed(Duration(milliseconds: 200));
      // this.write(message: kStart1);
      // await Future.delayed(Duration(milliseconds: 200));
      this.write(message: kStart2);
      await Future.delayed(Duration(milliseconds: 200));
      this.write(message: kStart3);
      // await Future.delayed(Duration(milliseconds: 200));
      // this.write(message: kStart2_2);
      // await Future.delayed(Duration(milliseconds: 200));
      // this.write(message: kStart2_2);
      // await Future.delayed(Duration(milliseconds: 200));
      // this.write(message: kStart4);
      // await Future.delayed(Duration(milliseconds: 200));
      // this.write(message: kStart5);
      // await Future.delayed(Duration(milliseconds: 200));
      // this.write(message: kStart4);
    }
  }

  /// Request maximum MTU for android device.
  // void _requestMTU() async {
  //   try {
  //     await this.device.requestMtu(512);
  //   } catch (e) {
  //     print('MTU Request error: $e');
  //   }
  // }

  /// Disconnected Event(Device stage) handler
  void _onDisconnected() async {
    print('Lost connection from ${this.displayName}');
    print(userDisconnect);
    if (!this.userDisconnect &&
        this.onceConnected &&
        Setting.currentContext != null) {
      Snackbar.show(Setting.currentContext!,
          text: 'Lost connection from ${this.displayName}');
    }
    this.userDisconnect = false;
    this.isExpanding = false;
    this.lastKnownState = BluetoothDeviceState.disconnected;
    await this.inputSubscribe?.cancel();
    await Future.delayed(Duration(milliseconds: 200));
    _classroom.sortList(ReorderType.disconnected, this.id());
    if (this.isMaster) _classroom.masterDisconnected();
  }

  /// Disconnect device
  Future disconnect() async {
    userDisconnect = true;
    await this.device.disconnect();
  }

  Future _getMIDIService() async {
    List<BluetoothService> _services = await this.device.discoverServices();
    this.service = _services.firstWhere((d) => d.uuid == kMIDIService);
    if (this.service == null) {
      print('Service not found! Disconnect.');
      await this.disconnect();
      throw 'no MIDI Service';
    }
  }

  // ///Discover device's service with timeout [kDiscoverServiceTimeout] seconds
  // ///Throw error on timeout event.
  // Future<List<BluetoothService>> _doDiscoverService() async =>
  //     await this.device.discoverServices();
  // return result.timeout(kDiscoverServiceTimeout, onTimeout: () {
  //   throw ('Discover service timeout');
  // });
  // Future result = await this.device.discoverServices();
  // return result.timeout(kDiscoverServiceTimeout, onTimeout: () {
  //   throw ('Discover service timeout');
  // });

  ///Get & Store MIDI characteristic.
  Future _getMIDICharacteristic() async {
    this.characteristic = this
        .service!
        .characteristics
        .firstWhere((d) => d.uuid == kMIDICharacteristic);
    if (this.characteristic == null) {
      print('Characteristic not found! Disconnect.');
      await this.disconnect();
      throw 'no MIDI Characteristic';
    }
  }

  /// Listen to host's key with time functioning.
  ///
  /// - When time between 2 incoming message is shorter than [Classroom.noteDelayMillisec],
  ///   app will add some delay to space between each outgoing message.
  /// - Later notes will have delay build up if there is other messages
  ///   still in queue.
  /// - In the queue, for message shorter than [Classroom.noteDelayMillisec],
  ///   app will add delay until meets with [Classroom.noteDelayMillisec].
  ///   But for message longer than [Classroom.noteDelayMillisec], app will keep the
  ///   duration by add time to [_extraDelay] for this message.
  /// - Exception is, above logic will only apply when there are more than
  ///   [kNoteCountWithoutDelay] in the sequence. Otherwise app will not add
  ///   any delay. For example, There will be no delay when user press chord
  ///   (3-4 notes)
  int _delay = 0;
  int _queueEnd = DateTime.now().millisecondsSinceEpoch;
  int _lastPressed = DateTime.now().millisecondsSinceEpoch;
  int _inQueueCount = 0;
  Future listenTo() async {
    await this.characteristic!.setNotifyValue(true);
    this.isListening = true;
    this.inputSubscribe = this.characteristic!.value.listen((List<int> data) {
      print('Retrieve: $data from ${this.displayName}');

      ///To record
      if (Setting.isRecording) _recorder.record(raw: data);

      /// if (DateTime.now().millisecondsSinceEpoch >=
      ///     (_queueEnd + kNoteDelayMillisec)) {
      int _extraDelay = 0;
      int _sinceLastPress =
          DateTime.now().millisecondsSinceEpoch - _lastPressed;
      if (_sinceLastPress > Setting.noteDelayMillisec) {
        /// If last note longer than time limit, prepare extra delay in case
        /// this note need to be in the queue.
        _extraDelay = _sinceLastPress - Setting.noteDelayMillisec;
      }

      /// To check if this note need to be in queue.
      if (DateTime.now().millisecondsSinceEpoch >=
          (_queueEnd + Setting.noteDelayMillisec)) {
        /// Current note is later than last queue, can continue without delay.
        _queueEnd =
            DateTime.now().millisecondsSinceEpoch + Setting.noteDelayMillisec;
        _delay = 0;
        _inQueueCount = 0;
      } else {
        /// There is a queue ahead need to add delay for this note.
        if (_inQueueCount > Setting.asChord) {
          _queueEnd += Setting.noteDelayMillisec + _extraDelay;
          _delay = (_queueEnd - DateTime.now().millisecondsSinceEpoch);
          _inQueueCount++;
        } else {
          _inQueueCount++;
        }
      }
      TimerStream(data, Duration(milliseconds: _delay)).listen((_data) {
        ///Otherwise it's unknown message.
        if (_data.length >= 5) {
          /// Listening function from host's key.
          final Uint8List _uintData = Uint8List.fromList(_data);
          if (Setting.sessionMode == SessionMode.offline) {
            _classroom.localMessageBroadcast(_uintData);
          } else if (Setting.sessionMode == SessionMode.online) {
            // if (_online.isRoomHost) _classroom.staffDisplay(_uintData);
            _online.broadcastMessage(_uintData);
          }
        }
      });
      _lastPressed = DateTime.now().millisecondsSinceEpoch;
    }, onError: (e) => print('listen error: $e}'));
  }

  /// Cancel listener.
  Future cancelListen() async {
    await this.characteristic!.setNotifyValue(false);
    await this.inputSubscribe?.cancel();
    this.isListening = false;
    print('canceled');
  }

  /// Write MIDI data to device.
  Future write({required Uint8List message}) async {
    if (this.characteristic != null) {
      print('BLE write: ${message.toString()}');
      await this.characteristic!.write(message, withoutResponse: true);
    }
  }

  ///Check if device is Pop Piano since it has difference connection method.
  bool _isPopPiano() => (this.device.name.contains('POP Piano') ||
      this.device.name.contains('POP piano') ||
      this.device.name.contains('pop piano') ||
      this.device.name.contains('pop Piano') ||
      this.device.name.contains('Pop Piano'));

  Future writeLightMessage(int key, noteSwitch) async {
    // int _lightSwitch;
    // Uint8List _out;
    // if (noteSwitch == kNoteOn) {
    //   _lightSwitch = lightOnMessage();
    //   // _isPopPiano()
    //   //     ? _lightSwitch = kLightOnRedPopPiano
    //   //     : _lightSwitch = kLightOnRed;
    //   // if (_classroom.isHolding) _classroom.holdingKeys.add(key);
    // } else {
    //   _lightSwitch = kLightOff;
    // }
    // _isPopPiano() ? _out = kLightMessagePopPiano : _out = kLightMessage;
    lightOnMessage() => _isPopPiano() ? kLightOnRedPopPiano : kLightOnRed;
    lightMessage() => _isPopPiano() ? kLightMessagePopPiano : kLightMessage;
    int _lightSwitch = noteSwitch == kNoteOn ? lightOnMessage() : kLightOff;
    Uint8List _out = lightMessage();
    _out[kLightKeyIndex] = key;
    _out[kLightSwitchIndex] = _lightSwitch;
    if (this.characteristic != null)
      await this.characteristic!.write(_out, withoutResponse: true);
  }

  void togglePing() => this.isOnPing = !this.isOnPing;

  void toggleConnecting(bool _is) => this.isConnecting = _is;

  Future toggleMaster(bool _isMaster) async {
    this.isMaster = _isMaster;
    (_isMaster) ? await this.listenTo() : await this.cancelListen();
  }

  void toggleExpanding() => this.isExpanding = !this.isExpanding;

  Future lightOffAllKeys() async {
    for (int _key = kFirstKey; _key <= kLastKey; _key++) {
      await this.writeLightMessage(_key, kNoteOff);
      await Future.delayed(Duration(milliseconds: Setting.noteDelayMillisec));
    }
  }
}
