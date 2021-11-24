import 'dart:async';
import 'package:everlong/services/setting.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/midi.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/device_db.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/online.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BluetoothControl extends ChangeNotifier {
  /// Import classes
  Classroom _classroom;
  DeviceDatabase _db;
  ListAnimation _ui;
  Online _online;
  Recorder _recorder;

  /// Flutter_blue
  FlutterBlue flutterBlue = FlutterBlue.instance;

  /// Set to true whe scanning for progress indicator.
  bool isReScan = true;

  /// Constructor
  BluetoothControl(this._classroom, this._online, this._recorder, this._db, this._ui);

  /// Scan bluetooth devices with timeout as [kScanDuration] and
  /// MIDI service as [kMIDIService].
  Future doScan({Duration timeout = kScanDuration, bool reScan = true}) async {
    isReScan = reScan;
    late StreamSubscription _sub;
    _sub = flutterBlue.isScanning.listen((scanning) async {
      if (!scanning)
        await flutterBlue
            .startScan(timeout: timeout, withServices: [kMIDIService]);
      _sub.cancel();
    });
  }

  /// Stop scan bluetooth device
  Future doStopScan() async => await flutterBlue.stopScan();

  /// Scan results will streaming as a duplicatable lists.
  /// So, app need to pick up only "Not listed" device.
  /// And return result for SetState purpose
  Stream<bool> collectScanResult() {
    var _success = flutterBlue.scanResults.map((results) {
      if (results.length > 0) {
        var _shouldUpdate = results
            .map((ScanResult e) => _filterDuplicate(result: e))
            .reduce((value, element) => element || value);
        return _shouldUpdate;
      } else {
        return false;
      }
    });
    return _success;
  }

  /// To prevent scan result duplicate. and store device to the list.
  bool _filterDuplicate({required ScanResult result}) {
    bool _success = false;
    print('scan result: ${result.device.name}');
    if (_classroom.bluetoothDevices
            .indexWhere((d) => d.id() == result.device.id.id) <
        0) {
      String _displayName =
          _db.getStoredName(id: result.device.id.id, name: result.device.name);
      BLEDevice _new = BLEDevice(_classroom, _online, _recorder,
          device: result.device, displayName: _displayName);
      _new.initDevice();
      _classroom.bluetoothDevices.add(_new);
      if (isReScan && _classroom.bluetoothDevices.length > 1) {
        _ui.listViewInsert(_classroom.bluetoothDevices.length - 1);
      }
      _success = true;
    } else {
      print('Duplicate to trash');
    }
    return _success;
  }

  /// When user scan while some devices still connected. These devices will
  /// be "invisible" to library (can be found in "connectedDevices").
  /// Therefore, If user disconnect these devices and try to re-connect.
  /// Bluetooth library won't be able to find device and connect to.
  ///
  /// So, This function will try to connect normally first, but if there is
  /// an exception occurred. app will try to re-scan(to refresh library list
  /// since now device has been disconnected).
  /// Then try to re-connect again.
  Future<ConnectionResult> connectTo(BLEDevice device) async {
    ConnectionResult _isSuccess = await device.connect(kConnectTimeout);
    if (_isSuccess == ConnectionResult.failed) {
      await Future.delayed(kConnectTimeout);
      await doScan(timeout: kAutoReScanDuration);
      await Future.delayed(kAutoReScanDuration);
      _isSuccess = await device.connect(kConnectTimeout);
    }
    if (_isSuccess == ConnectionResult.success) _classroom.devicesIncrement();
    return _isSuccess;
  }
}
