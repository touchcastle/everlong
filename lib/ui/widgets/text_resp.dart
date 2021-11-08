import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/constants.dart';

/// Responsive Text
/// Use [ratio] as screen's width divider for determine font size.
double textSizeResp({required double ratio}) {
  double _screenWidth = Setting.deviceWidth;
  double _fontSize() => _screenWidth <= kTabletStartWidth
      ? _screenWidth / (ratio)
      : _screenWidth <= kTabletMaxDynamicWidth
          ? _screenWidth / ((ratio) + 15)
          : _screenWidth / ((ratio) + 30);
  return _fontSize();
}
