import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/scroll_text.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

enum MessageType {
  error,
  info,
}

class Snackbar {
  static double _dialogRatio() => Setting.isTablet() ? 0.2 : 0.1;
  static void show(
    BuildContext context, {
    required String text,
    String? actionLabel,
    Function()? action,
    String? icon,
    MessageType type = MessageType.error,
    bool verticalMargin = true,
    bool fullWidth = false,
    Color? bgColor,
  }) {
    double _verticalMargin() => verticalMargin ? 0.07 : 0.02;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.symmetric(
        horizontal: fullWidth ? 10 : Setting.deviceWidth * _dialogRatio(),
        vertical: Setting.deviceHeight * _verticalMargin(),
      ),
      backgroundColor: bgColor != null
          ? bgColor
          : type == MessageType.error
              ? kErrorSnackBoxBg
              : kTextColorWhite,
      shape: RoundedRectangleBorder(borderRadius: kAllBorderRadius),
      content: Row(
        children: [
          type == MessageType.error
              ? svgIcon(
                  name: icon ?? kErrorIcon,
                  width: kIconWidth,
                  color: type == MessageType.error
                      ? kErrorSnackBoxText
                      : kTextColorDark)
              : SizedBox.shrink(),
          SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 14,
                    color: type == MessageType.error
                        ? kErrorSnackBoxText
                        : kTextColorDark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      duration: actionLabel != null
          ? action != null
              ? Duration(seconds: 8)
              : Duration(seconds: 10)
          : Duration(seconds: 4),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: kErrorSnackBoxText,
              onPressed: action ??
                  () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            )
          : null,
    ));
  }
}
