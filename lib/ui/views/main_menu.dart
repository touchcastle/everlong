import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/url_navigator.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/tutorial.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/ui/widgets/logo.dart';
import 'package:everlong/ui/widgets/actions/main_menu_button.dart';
import 'package:everlong/ui/widgets/actions/help.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';

class MainMenu extends StatefulWidget {
  static const id = kMainMenuId; //for route.

  @override
  _MainMenuState createState() => new _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final double _iconSpace = 20;

  @override
  void initState() {
    super.initState();
    Setting.sessionMode = SessionMode.none;
    UrlHandler.handleDynamicLink(context);
  }

  Row orDivider() => Row(
        children: [
          Expanded(child: Divider(color: kOrangeMain)),
          Text(kOr, style: TextStyle(color: kOrangeMain, fontSize: 12)),
          Expanded(child: Divider(color: kOrangeMain)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    Setting.deviceWidth = MediaQuery.of(context).size.width;
    Setting.deviceHeight = MediaQuery.of(context).size.height;
    double _dialogRatio() =>
        Setting.isTablet() ? kTabletMainMenuBtnRatio : kMobileMainMenuBtnRatio;
    double _logoRatio() => Setting.isTablet() ? kLogoTablet : kLogoMobile;
    return Scaffold(
      backgroundColor: kGreenMain,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo(_logoRatio),
              SizedBox(height: Setting.deviceHeight * 0.01),
              Text('$kVersionLabel $kVersion',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
              SizedBox(height: Setting.deviceHeight * 0.1),
              Container(
                constraints: BoxConstraints(
                    maxWidth: Setting.deviceWidth * _dialogRatio()),
                child: Column(
                  children: [
                    MainMenuButton(buttonType: ButtonType.create),
                    SizedBox(height: _iconSpace),
                    MainMenuButton(buttonType: ButtonType.join),
                    SizedBox(height: _iconSpace),
                    orDivider(),
                    SizedBox(height: _iconSpace),
                    MainMenuButton(buttonType: ButtonType.local),
                  ],
                ),
              ),
              SizedBox(height: Setting.deviceHeight * 0.03),
              Help(),
              // TextButton(
              //   child: Text('Tutorial'),
              //   onPressed: () {
              //     Navigator.of(context).push(PageRouteBuilder(
              //         transitionDuration: kTransitionDur,
              //         transitionsBuilder: kPageTransition,
              //         pageBuilder: (_, __, ___) => Tutorial()));
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
