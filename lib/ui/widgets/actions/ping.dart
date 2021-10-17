import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

///Generate ping device button with color ween animation.
///[_animationController]
class Ping extends StatefulWidget {
  Ping({required this.device});
  final BLEDevice device;

  @override
  _PingState createState() => new _PingState();
}

class _PingState extends State<Ping> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: kPingColorTweenDuration);
    _colorTween = kPingColorTween(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPingAll = context.watch<Classroom>().isPingAll;
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Button(
          icon: svgIcon(
            name: kPingIcon,
            color: _isPingAll
                ? null
                : widget.device.isOnPing
                    ? _colorTween.value
                    : kTextColorDark,
          ),
          onPressed: () async {
            if (!widget.device.isOnPing) {
              context.read<Classroom>().pingDevice(widget.device);
              for (int _i = 1; _i <= kNotifyTimes * 2; _i++) {
                _animationController.status == AnimationStatus.completed
                    ? await _animationController.reverse()
                    : await _animationController.forward();
              }
            }
          }),
    );
  }
}
