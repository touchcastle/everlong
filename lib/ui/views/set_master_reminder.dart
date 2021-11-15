import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/ok.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/texts.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/colors.dart';

// Widget renameDialog(BuildContext context, BLEDevice device) {

class SetMasterReminder extends StatefulWidget {
  @override
  _SetMasterReminderState createState() => new _SetMasterReminderState();
}

class _SetMasterReminderState extends State<SetMasterReminder> {
  bool _notShowAgain = false;

  EdgeInsetsGeometry _horizontalPadding =
      EdgeInsets.symmetric(horizontal: Setting.deviceWidth * 0.03);

  SizedBox _vertSpace() => SizedBox(height: Setting.deviceHeight * 0.015);

  @override
  Widget build(BuildContext context) {
    // final double _screenWidth = MediaQuery.of(context).size.width;
    // final double _screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(kBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.2, 0.9],
          colors: kLocalBG,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dialogHeaderBar(
              barColor: kLocalAccentColor,
              withExitIcon: false,
              titleIconName: kHostIcon,
              title: kSetMasterHeader,
            ),
            _vertSpace(),
            Padding(
              padding: _horizontalPadding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(kSetMasterInfo,
                    style: dialogSubHeader(color: kTextColorRed)),
              ),
            ),
            _vertSpace(),
            Padding(
              padding: _horizontalPadding,
              child: Image(image: AssetImage(kMasterReminderImage)),
            ),
            _vertSpace(),
            GestureDetector(
              onTap: () {
                setState(() {
                  _notShowAgain = !_notShowAgain;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  svgIcon(
                      name: _notShowAgain ? kCheckedIcon : kUncheckedIcon,
                      width: 16),
                  Text('  $kSetMasterNotShow',
                      style: dialogSubHeader(color: kTextColorRed))
                ],
              ),
            ),
            _vertSpace(),
            Container(
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(kBorderRadius),
              //     color: Color(0xffF9CC58)),
              child: OkOrCustomButton(
                labelColor: kLocalAccentColor,
                borderRadius: kAllBorderRadius,
                bgColor: kYellow2,
                onPressed: () {
                  if (_notShowAgain) {
                    Setting.saveBool(kMasterRemindPref, true);
                    Setting.notRemindMaster = true;
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
