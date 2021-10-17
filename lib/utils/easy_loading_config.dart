import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:everlong/utils/colors.dart';

void configLoading() {
  EasyLoading.instance
    // ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.wave
    ..loadingStyle = EasyLoadingStyle.custom
    // ..indicatorSize = 45.0
    // ..radius = 10.0
    ..progressColor = kTextColorLight
    ..backgroundColor = kDarkOnlineBG
    ..indicatorColor = kTextColorWhite
    ..textColor = kTextColorWhite;
  // ..maskColor = Colors.blue.withOpacity(0.5)
  // ..userInteractions = true
  // ..dismissOnTap = false
  // ..customAnimation = CustomAnimation();
}
