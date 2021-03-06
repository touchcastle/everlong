import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

/// Exit button
class Exit extends StatelessWidget {
  final Function()? onPressed;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final Color? bgColor;
  Exit({
    this.onPressed,
    this.color,
    this.borderRadius,
    this.bgColor,
  });
  @override
  Widget build(BuildContext context) {
    return Button(
      borderRadius: this.borderRadius,
      bgColor: bgColor,
      icon: svgIcon(
          name: kExitIcon,
          width: kIconWidth,
          color: buttonLabelColor(color: color)),
      onPressed: onPressed ?? () => Navigator.pop(context),
    );
  }
}
