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

Widget confirmDialog(
  BuildContext context, {
  required Function() onConfirm,
  String icon = kBluetoothIconDisconnected,
  Color headerColor = kTextColorLight,
  String header = kConfirmHeader,
  String detail = kConfirmInfo,
  Color detailColor = kTextColorWhite,
  Color bgColor = kGreen2,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: kAllBorderRadius,
      color: bgColor,
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
              svgIcon(name: icon, width: 30, color: headerColor),
              SizedBox(width: 15),
              Text(
                header,
                style: TextStyle(
                  color: headerColor,
                  fontSize: textSizeResp(ratio: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            detail,
            style: TextStyle(
              color: detailColor,
              fontSize: textSizeResp(ratio: 30),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OkOrCustomButton(label: kCancel, icon: kCancelIcon),
              OkOrCustomButton(onPressed: onConfirm, label: kConfirm),
            ],
          )
        ],
      ),
    ),
  );
}
