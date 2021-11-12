import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/text_resp.dart';
import 'package:everlong/ui/widgets/actions/ok.dart';
import 'package:everlong/ui/widgets/setting/latency.dart';
import 'package:everlong/ui/widgets/setting/listen_mode.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/icons.dart';
import 'package:flutter/rendering.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:flutter/widgets.dart';

Widget confirmExitDialog(BuildContext context, {required Function() onExit}) {
  // double _dialogRatio = Setting.isTablet() ? 0.6 : 0.8;

  return Container(
    // width: Setting.deviceWidth * _dialogRatio,
    // height: 240,
    decoration: BoxDecoration(
      borderRadius: kAllBorderRadius,
      gradient: kBGGradient(kSessionEndedBG),
      // color: Colors.red,
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
                'Leave room?',
                style: TextStyle(
                  color: kTextColorLight,
                  fontSize: textSizeResp(ratio: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Are you sure you want to leave room?',
            style: TextStyle(
              color: kTextColorWhite,
              fontSize: textSizeResp(ratio: 30),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OkOrCustomButton(label: 'Cancel', icon: kCancelIcon),
              OkOrCustomButton(onPressed: onExit, label: 'Confirm'),
            ],
          )
        ],
      ),
    ),
  );
}
