import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/ui/widgets/setting/latency.dart';
import 'package:everlong/ui/widgets/setting/listen_mode.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/icons.dart';
import 'package:flutter/rendering.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';

Widget settingDialog(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(kBorderRadius),
      gradient: kBGGradient(kSettingBG),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dialogHeaderBar(
          barColor: kLocalAccentColor,
          exitIconAreaColor: kYellowMain,
          exitIconColor: kTextColorRed,
          titleIconName: kSettingIcon,
          titleIconColor: Colors.white,
          title: 'Setting',
          titleColor: Colors.white,
        ),
        SizedBox(height: Setting.deviceHeight * 0.01),
        LatencySelect(),
        SizedBox(height: Setting.deviceHeight * 0.03),
        ModeSelect(),
        SizedBox(height: Setting.deviceHeight * 0.01),
        Text('version: $kVersion',
            style: TextStyle(color: kGreen2, fontSize: 8)),
        SizedBox(width: 5),
        // Back(),
      ],
    ),
  );
}
