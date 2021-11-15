import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/texts.dart';

class Save extends StatelessWidget {
  final Function() onPressed;
  Save({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      isVertical: false,
      bgColor: kYellow2,
      borderRadius: kAllBorderRadius,
      text: Text(
        kSave,
        style: buttonTextStyle(color: kTextColorRed, isDialogButton: true),
        textAlign: TextAlign.center,
      ),
      icon: svgIcon(
        name: kSaveIcon,
        width: kIconWidth,
        color: kTextColorRed,
      ),
      onPressed: this.onPressed,
    );
  }
}
