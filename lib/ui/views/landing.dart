import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/device_db.dart';
import 'package:everlong/services/staff.dart';
import 'package:everlong/ui/views/main_menu.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/images.dart';

class LandingScreen extends StatefulWidget {
  static const id = kLandingId; //for route.

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  void _readStoredDevices() async =>
      context.read<DeviceDatabase>().databaseDeviceName =
          await context.read<DeviceDatabase>().dbQueryDevice();

  void _appInitialize() async {
    try {
      context
          .read<BluetoothControl>()
          .doScan(timeout: kScanDuration, reScan: false);
      await Future.delayed(kScanDuration);
      context.read<Classroom>().keepAwake();
      Staff.staffList = Staff.genStaffList();
      context.read<Classroom>().piano.keyList =
          context.read<Classroom>().piano.generateKeysList();
      // UrlHandler.handleDynamicLink(context);
      await context.read<Online>().initFirebase();
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          settings: RouteSettings(name: kMainPageName),
          transitionDuration: kLandingTransitionDur,
          transitionsBuilder: kPageTransition,
          pageBuilder: (_, __, ___) => MainMenu()));
    } catch (e) {
      print('Initial scan error: $e');
    }
  }

  @override
  void initState() {
    Setting.sessionMode = SessionMode.none;
    Setting.initialize(context);
    _readStoredDevices();
    _appInitialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    double _logoRatio() => _screenWidth >= kTabletStartWidth ? kLogoTablet : kLogoMobile;
    return Scaffold(
      backgroundColor: kGreenMain,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Center(
          child: Hero(
            tag: kHeroLogo,
            child: SizedBox(
              width: _screenWidth * _logoRatio(),
              child: Image(
                image: AssetImage(kLogoImage),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
