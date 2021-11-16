import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/constants.dart';

class Button extends StatefulWidget {
  @override
  _ButtonState createState() => _ButtonState();
  Button({
    required this.icon,
    this.text,
    required this.onPressed,
    this.onLongPressed,
    this.borderRadius,
    this.isActive = false,
    this.isExpanded = false,
    this.isVertical = true,
    this.isTextCenter = false,
    this.align = MainAxisAlignment.center,
    this.bgColor,
    this.paddingVertical = 0,
    this.paddingHorizontal = 0,
    this.elevation,
  });

  ///Icon to be display.
  final Widget icon;

  ///Text to be display.
  final Widget? text;

  ///Function when press button.
  final Function() onPressed;

  ///Function when long press button.
  final Function()? onLongPressed;

  ///Flag to change button's color when it's active.
  final bool isActive;

  ///To make button expand to full parent's width
  final bool isExpanded;

  ///To display icon on top of text.
  final bool isVertical;

  ///To center displaying text only. (Different with [align] that effect to both
  ///icon and text)
  final bool isTextCenter;

  ///Alignment of both icon and text.
  final MainAxisAlignment align;

  ///Border radius of button, will effect to Inkwell widget as well.
  final BorderRadiusGeometry? borderRadius;

  ///Background color of button.
  final Color? bgColor;

  ///Vertical padding inside button
  final double paddingVertical;

  ///Horizontal padding inside button
  final double paddingHorizontal;

  ///Button's elevation
  final double? elevation;
}

class _ButtonState extends State<Button> {
  final double _defaultButtonPadding = 8;

  @override
  Widget build(BuildContext context) {
    late Widget _show;
    double? _width;
    if (widget.text != null) {
      //Text & Icon
      Widget _buttonContent({required List<Widget> children}) =>
          widget.isVertical
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: children,
                )
              : Row(
                  mainAxisAlignment: widget.align,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                );

      _show = _buttonContent(children: [
        widget.icon,
        widget.isVertical ? SizedBox(height: 3) : SizedBox(width: 10),
        widget.isTextCenter
            ? Expanded(child: widget.text!)
            : SizedBox(child: widget.text!),
      ]);
      if (widget.isVertical && Setting.deviceWidth >= kTabletStartWidth) {
        _width = 110;
      } else if (widget.isVertical && Setting.deviceWidth < kTabletStartWidth) {
        _width = 70;
      }
    } else {
      //Icon only
      _show = widget.icon;
      _width = 42;
    }

    final BoxConstraints _constraints =
        BoxConstraints(minHeight: kButtonMinHeight);

    Widget _cover({required Widget child}) => (_width != null)
        ? SizedBox(width: _width, child: child)
        : widget.isExpanded
            ? Expanded(flex: 1, child: child)
            : Container(child: child);

    return _cover(
      child: Material(
        borderRadius: widget.borderRadius ?? null,
        color: widget.isActive
            ? Colors.black12
            : widget.bgColor ?? Colors.transparent,
        elevation: widget.elevation ?? 0,
        shadowColor: Colors.black45,
        child: Container(
          constraints: _constraints,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              splashColor: Colors.black12,
              splashFactory: InkRipple.splashFactory,
              onTap: widget.onPressed,
              onLongPress: widget.onLongPressed,
              customBorder: widget.borderRadius != null
                  ? RoundedRectangleBorder(
                      borderRadius: widget.borderRadius!,
                    )
                  : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: _defaultButtonPadding + widget.paddingVertical,
                    horizontal: widget.isVertical
                        ? 0
                        : _defaultButtonPadding + widget.paddingHorizontal),
                // horizontal: 0),
                child: Container(
                  // color: Colors.blue,
                  child: _show,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
