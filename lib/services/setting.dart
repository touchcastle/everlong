import 'package:everlong/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'package:wakelock/wakelock.dart';
import 'package:connectivity/connectivity.dart';

///Mode for local session.
enum ListenMode {
  /// Trigger only light when host pressed keys.
  onMute,

  /// Trigger both sound and light when host pressed keys.
  onBlind,

  /// Trigger both sound and light when host pressed keys.
  on,

  /// Device will not listen to host.
  off,
}

///Current application state.
enum SessionMode {
  ///Local session.
  offline,

  ///Online session.
  online,

  ///Main menu
  none,
}

class Setting {
  static late double noteDelayScale; //Default setting
  static late int noteDelayMillisec; //Default setting
  static ListenMode appListenMode = ListenMode.onMute;
  static int asChord = 3;
  static late SessionMode sessionMode;
  static bool onlineMenuInStack = false;
  static bool inOnlineClass = false;
  static String? prefName;
  static late double deviceWidth;
  static late double deviceHeight;

  static void initialize(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    ///Delay scale
    final _scale = prefs.getInt('delay') ?? 20;
    // final _scale = 20;
    noteDelayScale = _scale.toDouble();

    ///Mode
    final _modeString = prefs.getString('mode') ?? 'ListenMode.onMute';
    changeMode(_mode(_modeString));

    ///Name
    prefName = prefs.getString('name');

    ///Prevent screen saver
    await Wakelock.enable();

    ///Get screen width & height
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
  }

  static ListenMode _mode(String str) => (str == ListenMode.off.toString())
      ? ListenMode.off
      : (str == ListenMode.onMute.toString())
          ? ListenMode.onMute
          : (str == ListenMode.onBlind.toString())
              ? ListenMode.onBlind
              : ListenMode.on;

  static void saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static void saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static void changeDelay(double scale) {
    noteDelayScale = scale;
    appListenMode == ListenMode.on
        ? noteDelayMillisec = noteDelayScale.toInt() + 30
        : noteDelayMillisec = noteDelayScale.toInt() + 10;
    saveInt('delay', noteDelayScale.toInt());
  }

  static void changeMode(ListenMode mode) {
    appListenMode = mode;
    if (appListenMode == ListenMode.on) asChord = 0;
    saveString('mode', mode.toString());
    changeDelay(noteDelayScale);
  }

  static Future<String> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  static Future<String> getName() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.name; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.model; // unique ID on Android
    }
  }

  static Future<bool> isConnectToInternet() async {
    ConnectivityResult _result = await Connectivity().checkConnectivity();
    if (_result == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  static isOnline() => Setting.sessionMode == SessionMode.online;
  static isOffline() => Setting.sessionMode == SessionMode.offline;
  static bool isTablet() => Setting.deviceWidth >= kTabletStartWidth;
}
