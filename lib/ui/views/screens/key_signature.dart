import 'package:flutter/material.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/styles.dart';

///Key's signature image display.
Widget keyImage({
  required KeySig keySig,
  required double width,
  required double height,
}) {
  ///Padding for Ker G image.(May need to change if image was changed).
  final EdgeInsetsGeometry _keyGImagePadding = EdgeInsets.only(top: 108);

  ///Padding for Ker F image.(May need to change if image was changed).
  final EdgeInsetsGeometry _keyFImagePadding = EdgeInsets.only(top: 1, left: 5);

  ///Widget's width(May need to change if image was changed)
  Widget _keyFImage() => svgIcon(name: kKeyFImage, width: 45);
  Widget _keyGImage() => svgIcon(name: kKeyGImage, width: 33);

  double _clefArea() => width / kClefAreaProportion;

  return SizedBox(
    width: _clefArea(),
    child: Padding(
      padding: keySig == KeySig.f ? _keyFImagePadding : _keyGImagePadding,
      child: keySig == KeySig.f ? _keyFImage() : _keyGImage(),
    ),
  );
}
