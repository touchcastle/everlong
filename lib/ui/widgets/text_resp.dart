import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/constants.dart';

/// Responsive Text
/// Use [ratio] as screen's width divider for determine font size.
double textSizeResp({required double ratio, double? max}) {
  double _screenWidth = Setting.deviceWidth;
  double _fontSize() => _screenWidth <= kTabletStartWidth
      ? _screenWidth / (ratio)
      : _screenWidth <= kTabletMaxDynamicWidth
          ? _screenWidth / ((ratio) + 15)
          : _screenWidth / ((ratio) + 30);
  if (max != null) print(_fontSize());
  double _out() => max != null && max < _fontSize() ? max : _fontSize();
  return _out();
}
