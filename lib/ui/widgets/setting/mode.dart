import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';

Widget mode(BuildContext context, ListenMode mode,
    {required void onPressed()}) {
  Widget _modeList(
      {required MainAxisAlignment mainAxisAlignment,
      required List<Widget> children}) {
    if (Setting.isTablet()) {
      return Column(children: children);
    } else {
      return Row(mainAxisAlignment: mainAxisAlignment, children: children);
    }
  }

  TextAlign _textAlign() =>
      Setting.isTablet() ? TextAlign.center : TextAlign.start;
  Widget _leader() =>
      Setting.isTablet() ? SizedBox.shrink() : SizedBox(width: 20);
  Widget _spacer() =>
      Setting.isTablet() ? SizedBox(height: 10) : SizedBox(width: 15);
  Widget _cover({required Widget child}) => Setting.isTablet()
      ? SizedBox(height: 45, child: child)
      : Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: SizedBox(child: child)),
        );

  String _text() => mode == ListenMode.off
      ? kSettingModeOff
      : mode == ListenMode.on
          ? Setting.isTablet()
              ? kSettingModeOnTablet
              : kSettingModeOn
          : mode == ListenMode.onMute
              ? Setting.isTablet()
                  ? kSettingModeOnMuteTablet
                  : kSettingModeOnMute
              : kSettingModeOnBlind;

  Color _color() =>
      mode == Setting.appListenMode ? kTextColorDark : kTextColorRed;
  String _iconName() =>
      mode == Setting.appListenMode ? kCheckedIcon : kUncheckedIcon;

  return GestureDetector(
    onTap: onPressed,
    child: Container(
      color: Colors.transparent,
      child: _modeList(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _leader(),
          svgIcon(name: _iconName(), width: 20),
          _spacer(),
          _cover(
            child: Text(
              _text(),
              style: dialogDetail(color: _color()),
              textAlign: _textAlign(),
            ),
          ),
        ],
      ),
    ),
  );
}
