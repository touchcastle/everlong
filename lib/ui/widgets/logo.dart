import 'package:flutter/widgets.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/images.dart';
import 'package:everlong/utils/constants.dart';

Hero logo(double _logoRatio()) {
  return Hero(
    tag: kHeroLogo,
    child: SizedBox(
      width: Setting.deviceWidth * _logoRatio(),
      child: Image(
        image: AssetImage(kLogoImage),
      ),
    ),
  );
}
