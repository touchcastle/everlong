import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/text_resp.dart';
import 'package:everlong/ui/widgets/actions/ok.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

Widget confirmExitDialog(BuildContext context, {required Function() onExit}) {
  return Container(
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
                kExitHeader,
                style: TextStyle(
                  color: kTextColorLight,
                  fontSize: textSizeResp(ratio: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            kExitInfo,
            style: TextStyle(
              color: kTextColorWhite,
              fontSize: textSizeResp(ratio: 30),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OkOrCustomButton(label: kCancel, icon: kCancelIcon),
              OkOrCustomButton(onPressed: onExit, label: kConfirm),
            ],
          )
        ],
      ),
    ),
  );
}
