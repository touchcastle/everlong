import 'package:flutter/widgets.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/images.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:everlong/utils/constants.dart';

Hero logo(double _logoRatio()) {
  double _width() => Setting.deviceWidth * _logoRatio() > 700
      ? 700
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
