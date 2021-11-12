import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';

class OkOrCustomButton extends StatelessWidget {
  final Function()? onPressed;
  final String? label;
  final String? icon;
  OkOrCustomButton({this.onPressed, this.label, this.icon});
  @override
  Widget build(BuildContext context) {
    return Button(
        isVertical: false,
        text: Text(
          label ?? kOk,
          style: buttonTextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        icon: svgIcon(
            name: icon ?? kOkIcon, width: kIconWidth, color: Colors.white),
        onPressed: onPressed ?? () async => Navigator.pop(context));
  }
}
