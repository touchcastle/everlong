import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/ui/widgets/text_resp.dart';

///Font Family
const String kPrimaryFontFamily = 'Kanit';
const String kSecondaryFontFamily = 'Nunito';

///Border Radius
const Radius kBorderRadius = Radius.circular(8.0);
const BorderRadiusGeometry kAllBorderRadius = BorderRadius.all(kBorderRadius);
const BorderRadiusGeometry kBottom =
    BorderRadius.only(bottomRight: kBorderRadius, bottomLeft: kBorderRadius);
const BorderRadiusGeometry kTop =
    BorderRadius.only(topRight: kBorderRadius, topLeft: kBorderRadius);
const BorderRadiusGeometry kTopLeft = BorderRadius.only(topLeft: kBorderRadius);

///Container Decoration
const BoxDecoration kBoxDecor =
    BoxDecoration(color: kConnectedBoxColor, borderRadius: kAllBorderRadius);
const BoxDecoration kDeviceFxDecor =
    BoxDecoration(color: kConnectedBoxColor, borderRadius: kAllBorderRadius);
BoxDecoration kDialogDecor = BoxDecoration(
  borderRadius: kAllBorderRadius,
  color: Setting.isOnline() ? kOnlineDialog : kLocalDialog,
);
const BoxDecoration kOnlineLobbyDialogDecor = BoxDecoration(
  borderRadius: kAllBorderRadius,
  color: kDarkOnlineBG,
);

///Text input field decoration.
InputDecoration kRenameTextDecor(String hint) {
  return InputDecoration(
    // isDense: true,
    focusColor: Colors.green,
    isCollapsed: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    hintText: hint,
    counterText: '',
    hintStyle: TextStyle(
        fontSize: 18,
        color: Colors.black26,
        fontFamily: kPrimaryFontFamily,
        fontWeight: FontWeight.w500),
    filled: true,
    fillColor: kTextColorWhite,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: BorderSide(
        color: Colors.black,
        width: 2.0,
      ),
    ),
  );
}

///Theme data
TextSelectionThemeData kTextInputTheme =
    TextSelectionThemeData(selectionColor: Colors.green);

///TextStyle
///TextField
const TextStyle kTextFieldStyle = TextStyle(
  fontSize: 18,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);

///Related to device.
TextStyle noDeviceTextStyle() => TextStyle(
      color: Setting.isOnline() ? kTextColorLight : kTextColorDark,
      fontSize: textSizeResp(ratio: 30),
    );
const TextStyle kDeviceInfoName =
    TextStyle(color: kTextColorDark, fontWeight: FontWeight.w500, fontSize: 14);
const TextStyle kDeviceInfoId = TextStyle(color: kTextColorDark, fontSize: 14);

///Online
const TextStyle kMemberName = TextStyle(color: kMemberDetail, fontSize: 24);
const TextStyle kMemberInfo = TextStyle(color: kMemberDetail, fontSize: 14);

///Dialog Text Style
TextStyle dialogHeader({Color? color}) => TextStyle(
    fontSize: 22, fontWeight: FontWeight.w500, color: color ?? Colors.white);
TextStyle dialogSubHeader({Color? color}) => TextStyle(
    fontSize: 18, fontWeight: FontWeight.w500, color: color ?? Colors.white);
TextStyle dialogDetail({Color? color}) =>
    TextStyle(fontSize: 14, color: color ?? Colors.white);

///TextFieldLabel
TextStyle textFieldLabel({Color? color}) =>
    TextStyle(fontSize: 16, color: color ?? Colors.white);
TextStyle textFieldSubLabel({Color? color}) =>
    TextStyle(fontSize: 12, color: color ?? Colors.white);
TextStyle textFieldSubLabel2({Color? color}) =>
    TextStyle(fontSize: 12, color: color ?? Colors.white);

///Padding
// const EdgeInsets kMenuButton =
//     EdgeInsets.symmetric(vertical: 5, horizontal: 10);
const double kMenuVerticalPadding = 5;
const double kMenuHorizontalPadding = 10;
const EdgeInsets kDevicesAreaPadding = EdgeInsets.only(left: 0);
const EdgeInsets kDeviceBoxOuterPadding = EdgeInsets.only(bottom: 10);
const EdgeInsets kDeviceBoxInnerPadding =
    EdgeInsets.symmetric(horizontal: 15, vertical: 15);
const EdgeInsets kBottomPanePadding =
    EdgeInsets.symmetric(horizontal: 0, vertical: 0);
const EdgeInsets kTopPanePadding =
    EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5);
const EdgeInsets kDeviceFunctionPadding =
    EdgeInsets.symmetric(horizontal: 10, vertical: 8);
const EdgeInsets kOnlineLobby = EdgeInsets.only(bottom: 0);

///Color tween
Animation kColorTween(AnimationController controller) => Setting.isOnline()
    ? kOnlineColorTween.animate(controller)
    : kLocalColorTween.animate(controller);
Animation kPingColorTween(AnimationController controller) =>
    kDevicePingColorTween.animate(controller);

///Background gradient for all screen.
Gradient kBGGradient(List<Color> colors) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.2, 0.9],
      colors: colors,
    );

/// Gradient for edge of scrollable list.
const LinearGradient kListBorderGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    // Colors.black38,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
    Colors.transparent
    // Colors.black38,
  ],
  stops: [0.0, 0.01, 0.99, 1.0], // 10% purple, 80% transparent, 10% purple
);

///Area width proportion of music clef image.
const double kClefAreaProportion = 8.0;

///Button's Style
///Function to return button's text style from criteria.
TextStyle buttonTextStyle({
  ///When button is currently active.
  bool isActive = false,

  ///When button is vertical display.
  bool isVertical = false,

  ///When button is display in dialog.
  bool isDialogButton = false,

  ///Text Color
  Color? color,
}) {
  ///Button label color.
  Color _color = buttonLabelColor(isActive: isActive, color: color);

  return TextStyle(
    fontSize: isVertical
        ? kVerticalButtonTextSize
        : isDialogButton
            ? kDialogButtonTextSize
            : kButtonTextSize,
    color: color ?? _color,
  );
}
