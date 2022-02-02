import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/texts.dart';

class Save extends StatelessWidget {
  final Function() onPressed;
  Save({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      isVertical: false,
      // bgColor: kYellow2,
      bgColor: Setting.isOnline() ? kGreenMain : kYellow2,
      borderRadius: kAllBorderRadius,
      icon: svgIcon(
        name: kSaveIcon,
        width: kIconWidth,
        color: Setting.isOnline() ? Colors.white : kTextColorRed,
      ),
      text: Text(
        kSave,
        style: buttonTextStyle(
            color: Setting.isOnline() ? Colors.white : kTextColorRed,
            isDialogButton: true),
        textAlign: TextAlign.center,
      ),
      onPressed: this.onPressed,
    );
  }
}
