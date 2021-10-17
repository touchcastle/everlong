import 'package:flutter/material.dart';
import 'package:everlong/utils/icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgIcon(
    {required String name,
    double width = kIconWidth,
    double? height,
    Color? color}) {
  return SvgPicture.asset(
    name,
    width: width,
    height: height,
    color: color,
  );
}
