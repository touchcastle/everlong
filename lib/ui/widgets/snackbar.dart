import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/scroll_text.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';

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
    bool dialogWidth = false,
    Color? bgColor,
  }) {
    /// Config
    double _hMargin() =>
        Setting.isTablet() ? kTabletDialogMargin : kMobileDialogMargin;
    double _vMargin() => verticalMargin ? kBottomActionWidth + 5 : 5;
    // double _vMargin() => verticalMargin ? 0.08 : 0.02;
    Color _textColor() =>
        // type == MessageType.error ? kErrorSnackBoxText : kTextColorDark;
        type == MessageType.error ? kErrorSnackBoxText : kErrorSnackBoxText;
    TextStyle _style() => TextStyle(fontSize: 13, color: _textColor());

    //BUILDER
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.symmetric(
        horizontal: dialogWidth
            ? Setting.deviceWidth * _hMargin()
            : kMainAreaHorizontalPadding,
        vertical: _vMargin(),
        // vertical: Setting.deviceHeight * _vMargin(),
      ),
      backgroundColor: bgColor != null
          ? bgColor
          : type == MessageType.error
              ? kErrorSnackBoxBg
              : kErrorSnackBoxBg,
      // : kErrorSnackBoxBg,
      shape: RoundedRectangleBorder(borderRadius: kAllBorderRadius),
      content: Row(
        children: [
          type == MessageType.error
              ? svgIcon(
                  name: icon ?? kErrorIcon,
                  width: kIconWidth,
                  color: _textColor())
              : SizedBox.shrink(),
          SizedBox(width: 10),
          Expanded(
            child: ScrollingText(text: text, textStyle: _style()),
            // child: LayoutBuilder(
            //   builder: (context, constraint) => _isOverflow(text, constraint)
            //       ? ScrollingText(text: text, textStyle: _style())
            //       : Text(text,
            //           style: _style(), overflow: TextOverflow.ellipsis),
            // ),
          ),
        ],
      ),
      duration:
          actionLabel != null ? Duration(seconds: 10) : Duration(seconds: 4),
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
