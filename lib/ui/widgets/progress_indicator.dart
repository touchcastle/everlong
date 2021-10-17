import 'package:flutter/material.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/ui/widgets/extends/custom_cupertino_indicator.dart';

Widget progressIndicator({bool animate = true, GestureTapCallback? onTap}) {
  return InkWell(
    child: CustomCupertinoActivityIndicator(
      animating: animate,
      radius: 13,
      color: buttonLabelColor(isActive: animate),
    ),
    onTap: onTap,
  );
}
