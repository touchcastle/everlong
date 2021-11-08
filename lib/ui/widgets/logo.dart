import 'package:flutter/widgets.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/constants.dart';

Hero logo(double _logoRatio()) {
  double _width() => Setting.deviceWidth * _logoRatio() > 650
      ? 650
      : Setting.deviceWidth * _logoRatio();

  return Hero(
    tag: kHeroLogo,
    child: SizedBox(
      width: _width(),
      child: Image(
        image: AssetImage(kLogoImage),
      ),
    ),
  );
}
