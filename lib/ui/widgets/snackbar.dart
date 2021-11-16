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

///Snackbar to display warning / error to user
///Custom margin for both horizontal and vertical from screen edge.
///Has parameter for display full width(still has 10px margin).
///
///Has logic to determine whether displaying text overflowed or not?
///if overflowed, display as auto scroll text [ScrollingText]
class Snackbar {
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
    double _hMargin() => Setting.isTablet() ? 0.2 : 0.1;
    double _vMargin() => verticalMargin ? 0.07 : 0.02;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.symmetric(
        horizontal: fullWidth ? 10 : Setting.deviceWidth * _hMargin(),
        vertical: Setting.deviceHeight * _vMargin(),
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
            child: LayoutBuilder(
              builder: (context, size) {
                // Build the Textspan
                var _span = TextSpan(
                  text: text,
                  style: TextStyle(
                      fontSize: 12,
                      color: type == MessageType.error
                          ? kErrorSnackBoxText
                          : kTextColorDark),
                );

                // Use a Textpainter to determine if it will exceed max lines
                var _tp = TextPainter(
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  textDirection: TextDirection.ltr,
                  text: _span,
                );

                // trigger it to layout
                _tp.layout(maxWidth: size.maxWidth);

                // whether the text overflowed or not
                var _exceeded = _tp.didExceedMaxLines;

                if (_exceeded) {
                  return ScrollingText(
                      text: text,
                      textStyle: TextStyle(
                          fontSize: 12,
                          color: type == MessageType.error
                              ? kErrorSnackBoxText
                              : kTextColorDark));
                } else {
                  return Text(
                    text,
                    style: TextStyle(
                        fontSize: 12,
                        color: type == MessageType.error
                            ? kErrorSnackBoxText
                            : kTextColorDark),
                    overflow: TextOverflow.ellipsis,
                  );
                }
              },
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
