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
    String? icon,
    MessageType type = MessageType.error,
    bool verticalMargin = true,
  }) {
    double _verticalMargin() => verticalMargin ? 0.08 : 0.02;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.symmetric(
        horizontal: Setting.deviceWidth * _dialogRatio(),
        vertical: Setting.deviceHeight * _verticalMargin(),
      ),
      backgroundColor:
          type == MessageType.error ? kErrorSnackBoxBg : kTextColorWhite,
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
            // child: ScrollingText(
            //   text: text,
            //   textStyle: TextStyle(
            //       fontSize: 14,
            //       color: type == MessageType.error
            //           ? kErrorSnackBoxText
            //           : kTextColorDark),
            // ),
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
      duration:
          actionLabel != null ? Duration(seconds: 10) : Duration(seconds: 4),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: kErrorSnackBoxText,
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            )
          : null,
    ));
  }
}
