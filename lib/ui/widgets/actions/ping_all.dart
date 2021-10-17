import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';

/// Generate ping all devices with color tween animation.
class PingAll extends StatefulWidget {
  @override
  _PingAllState createState() => new _PingAllState();
}

class _PingAllState extends State<PingAll> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: kPingColorTweenDuration);
    _colorTween = kColorTween(_animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPingAll = context.watch<Classroom>().isPingAll;
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Button(
        isActive: _isPingAll,
        icon: svgIcon(
          name: kPingIcon,
          width: kIconWidth2 - 0,
          color: _isPingAll
              ? _colorTween.value
              : Setting.isOnline()
                  ? kTextColorLight
                  : kLocalLabelColor,
        ),
        text: Text(kIdentAll,
            style: buttonTextStyle(isActive: _isPingAll, isVertical: true),
            textAlign: TextAlign.center),
        onPressed: () async {
          if (!_isPingAll) {
            if (context.read<Classroom>().anyConnected()) {
              context.read<Classroom>().pingAllDevices();
              for (int _i = 1; _i <= kNotifyTimes * 2; _i++) {
                _animationController.status == AnimationStatus.completed
                    ? await _animationController.reverse()
                    : await _animationController.forward();
              }
            } else {
              Snackbar.show(context, text: kNoConnectedMsg);
            }
          }
        },
        // isTiled: true,
      ),
    );
  }
}
