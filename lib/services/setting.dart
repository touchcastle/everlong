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
  static int asChord = Platform.isIOS ? 3 : 0;
  static late SessionMode sessionMode;
  static bool onlineMenuInStack = false;
  static bool inOnlineClass = false;
  static String? prefName;
  static double deviceWidth = 600;
  static double deviceHeight = 600;
  static BuildContext? currentContext;
  static int initScale = Platform.isIOS ? 20 : 60;
  static bool notRemindMaster = false;
  static bool isShowingDialog = false;

  static void initialize(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    ///Get screen width & height
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    ///Delay scale
    final _scale = prefs.getInt(kDelayPref) ?? initScale;
    // final _scale = 20;
    noteDelayScale = _scale.toDouble();

    ///Mode
    final _modeString = prefs.getString(kModePref) ?? 'ListenMode.onMute';
    changeMode(_mode(_modeString));

    ///Name
    prefName = prefs.getString(kNamePref);

    ///Remind Master Device Setting Dialog
    notRemindMaster = prefs.getBool(kMasterRemindPref) ?? false;

    ///Prevent screen saver
    await Wakelock.enable();
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

  static void saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static void changeDelay(double scale) {
    noteDelayScale = scale;
    appListenMode == ListenMode.on
        ? noteDelayMillisec = noteDelayScale.toInt() + 30
        : noteDelayMillisec = noteDelayScale.toInt() + 10;
    saveInt(kDelayPref, noteDelayScale.toInt());
  }

  static void changeMode(ListenMode mode) {
    appListenMode = mode;
    if (appListenMode == ListenMode.on) asChord = 0;
    saveString(kModePref, mode.toString());
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
