import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/texts.dart';

class OkOrCustomButton extends StatelessWidget {
  final Function()? onPressed;
  final String? label;
  final String? icon;
  final Color? labelColor;
  final Color? bgColor;
  final BorderRadiusGeometry? borderRadius;
  OkOrCustomButton({
    this.onPressed,
    this.label,
    this.icon,
    this.labelColor = Colors.white,
    this.bgColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
        isVertical: false,
        bgColor: bgColor,
        borderRadius: borderRadius,
        text: Text(
          label ?? kOk,
          style: buttonTextStyle(color: labelColor),
          textAlign: TextAlign.center,
        ),
        icon: svgIcon(
            name: icon ?? kOkIcon, width: kIconWidth, color: labelColor),
        onPressed: onPressed ?? () async => Navigator.pop(context));
  }
}
