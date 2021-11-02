import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';

class Ok extends StatelessWidget {
  final Function()? onPressed;
  Ok({this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Button(
        isVertical: false,
        text: Text(
          kOk,
          style: buttonTextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        icon: svgIcon(name: kOkIcon, width: kIconWidth, color: Colors.white),
        onPressed: onPressed ?? () async => Navigator.pop(context));
  }
}
