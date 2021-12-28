/// Custom CupertinoActivityIndicator by change color and size.
/// Custom code marked by //TJO+ , TJO-

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

// const double _kDefaultIndicatorRadius = 10.0;  //TJO-
const double _kDefaultIndicatorRadius = 7.0; //TJO+

const Color _kActiveTickColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF9F1A1A),
  darkColor: Color(0xFFFBF5EC),
);

/// An iOS-style activity indicator that spins clockwise.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=AENVH-ZqKDQ}
///
/// See also:
///
///  * <https://developer.apple.com/ios/human-interface-guidelines/controls/progress-indicators/#activity-indicators>
class CustomCupertinoActivityIndicator extends StatefulWidget {
  /// Creates an iOS-style activity indicator that spins clockwise.
  const CustomCupertinoActivityIndicator({
    Key? key,
    this.animating = true,
    required this.color,
    this.radius = _kDefaultIndicatorRadius,
  })  : assert(radius > 0.0),
        progress = 1.0,
        super(key: key);

  /// Creates a non-animated iOS-style activity indicator that displays
  /// a partial count of ticks based on the value of [progress].
  ///
  /// When provided, the value of [progress] must be between 0.0 (zero ticks
  /// will be shown) and 1.0 (all ticks will be shown) inclusive. Defaults
  /// to 1.0.
  const CustomCupertinoActivityIndicator.partiallyRevealed({
    Key? key,
    this.radius = _kDefaultIndicatorRadius,
    required this.color,
    this.progress = 1.0,
  })  : assert(progress >= 0.0),
        assert(progress <= 1.0),
        animating = false,
        super(key: key);

  /// Whether the activity indicator is running its animation.
  ///
  /// Defaults to true.
  final bool animating;

  final Color color;

  /// Radius of the spinner widget.
  ///
  /// Defaults to 10px. Must be positive and cannot be null.
  final double radius;

  /// Determines the percentage of spinner ticks that will be shown. Typical usage would
  /// display all ticks, however, this allows for more fine-grained control such as
  /// during pull-to-refresh when the drag-down action shows one tick at a time as
  /// the user continues to drag down.
  ///
  /// Defaults to 1.0. Must be between 0.0 and 1.0 inclusive, and cannot be null.
  final double progress;

  @override
  _CustomCupertinoActivityIndicatorState createState() =>
      _CustomCupertinoActivityIndicatorState();
}

class _CustomCupertinoActivityIndicatorState
    extends State<CustomCupertinoActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.animating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CustomCupertinoActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animating != oldWidget.animating) {
      if (widget.animating)
        _controller.repeat();
      else
        _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _activeTickColor() => CupertinoDynamicColor.withBrightness(
        color: widget.color,
        darkColor: Color(0xFFFBF5EC),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.radius * 2,
      width: widget.radius * 2,
      child: CustomPaint(
        painter: _CupertinoActivityIndicatorPainter(
          position: _controller,
          activeColor:
              CupertinoDynamicColor.resolve(_activeTickColor(), context),
          // CupertinoDynamicColor.resolve(_kActiveTickColor, context),
          focusColor: Color(0xFFFBF5EC), //TJO++
          animating: widget.animating, //TJO++
          radius: widget.radius,
          progress: widget.progress,
        ),
      ),
    );
  }
}

const double _kTwoPI = math.pi * 2.0;

/// Alpha values extracted from the native component (for both dark and light mode) to
/// draw the spinning ticks.
// < TJO+
const List<int> _kAlphaValues = <int>[
  255,
  255,
  255,
  255,
  255,
  255,
  128,
  47,
];
const List<int> _kAlphaValuesInactive = <int>[
  255,
  255,
  255,
  255,
  255,
  255,
  255,
  255,
];
// < TJO+
// < TJO-
// const List<int> _kAlphaValues = <int>[
//   47,
//   47,
//   47,
//   47,
//   72,
//   97,
//   122,
//   147,
// ];
// > TJO-

/// The alpha value that is used to draw the partially revealed ticks.
const int _partiallyRevealedAlpha = 255; //TJO+
// const int _partiallyRevealedAlpha = 147;   //TJO-

class _CupertinoActivityIndicatorPainter extends CustomPainter {
  _CupertinoActivityIndicatorPainter({
    required this.position,
    required this.activeColor,
    required this.focusColor, //TJO+
    required this.animating, //TJO+
    required this.radius,
    required this.progress,
  })
  // : tickFundamentalRRect =
  //       RRect.fromLTRBR(11, 18, 5, 5, Radius.circular(3)),
  : tickFundamentalRRect = RRect.fromLTRBXY(
          -radius / _kDefaultIndicatorRadius,
          // -radius / 3.0,       //TJO-
          -radius / 1.8, //TJO+
          radius / _kDefaultIndicatorRadius,
          // -radius,             //TJO-
          -radius / 0.9, //TJO+
          radius / _kDefaultIndicatorRadius,
          radius / _kDefaultIndicatorRadius,
        ),
        super(repaint: position);

  final Animation<double> position;
  final Color activeColor;
  final Color focusColor; //TJO+
  final bool animating; //TJO+
  final double radius;
  final double progress;

  final RRect tickFundamentalRRect;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final int tickCount = _kAlphaValues.length;

    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);

    final int activeTick = (tickCount * position.value).floor();

    for (int i = 0; i < tickCount * progress; ++i) {
      final int t = (i - activeTick) % tickCount;
      // >TJO+
      if (animating) {
        if (_kAlphaValues[t] == 47) {
          paint.color = focusColor;
        } else {
          paint.color = activeColor.withAlpha(
              progress < 1 ? _partiallyRevealedAlpha : _kAlphaValues[t]);
        }
      } else {
        paint.color = activeColor;
      } //TJO+
      canvas.drawRRect(tickFundamentalRRect, paint);
      canvas.rotate(_kTwoPI / tickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CupertinoActivityIndicatorPainter oldPainter) {
    return oldPainter.position != position ||
        oldPainter.activeColor != activeColor ||
        oldPainter.progress != progress;
  }
}
