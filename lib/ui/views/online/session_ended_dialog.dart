import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/actions/ok.dart';
import 'package:everlong/ui/widgets/text_resp.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/texts.dart';

Widget sessionEnded({required Function() onPressed}) {
  double _dialogRatio = Setting.isTablet() ? 0.5 : 0.7;

  return Center(
    child: Container(
      width: Setting.deviceWidth * _dialogRatio,
      decoration: BoxDecoration(
        borderRadius: kAllBorderRadius,
        gradient: kBGGradient(kSessionEndedBG),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                svgIcon(
                    name: kBluetoothIconDisconnected,
                    width: 30,
                    color: kTextColorLight),
                SizedBox(width: 15),
                Text(
                  kSessionEndedHeader,
                  style: TextStyle(
                    color: kTextColorLight,
                    fontSize: textSizeResp(ratio: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              kSessionEndedInfo,
              style: TextStyle(
                color: kTextColorWhite,
                fontSize: textSizeResp(ratio: 30),
              ),
            ),
            SizedBox(height: 20),
            OkOrCustomButton(onPressed: onPressed)
          ],
        ),
      ),
    ),
  );
}
