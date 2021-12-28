import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/views/setting/latency.dart';
import 'package:everlong/ui/views/setting/listen_mode.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

Widget settingDialog(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: kAllBorderRadius,
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
          title: kSettingHeader,
          titleColor: Colors.white,
        ),
        SizedBox(height: Setting.deviceHeight * 0.01),
        LatencySelect(),
        SizedBox(height: Setting.deviceHeight * 0.03),
        ModeSelect(),
        SizedBox(height: Setting.deviceHeight * 0.01),
        // Text('$kVersionLabel: $kVersion',
        //     style: TextStyle(color: kGreen2, fontSize: 8)),
        // SizedBox(width: 5),
        // Back(),
      ],
    ),
  );
}
