import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/url_navigator.dart';
import 'package:everlong/ui/widgets/logo.dart';
import 'package:everlong/ui/widgets/actions/main_menu_button.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

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
    double _dialogRatio() => Setting.isTablet() ? 0.45 : 0.7;
    double _logoRatio() => Setting.isTablet() ? 0.8 : 1;
    return Scaffold(
      backgroundColor: kGreenMain,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logo(_logoRatio),
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
              SizedBox(height: Setting.deviceHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
