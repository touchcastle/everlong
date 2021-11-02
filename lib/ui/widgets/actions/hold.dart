import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/progress_indicator.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

/// Generate hold button.
class Hold extends StatefulWidget {
  @override
  _HoldState createState() => _HoldState();
}

class _HoldState extends State<Hold> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: kPingColorTweenSlowDuration);
    _colorTween = kColorTween(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Button(
        isActive: context.watch<Classroom>().isHolding,
        icon: context.watch<Classroom>().isClearing
            ? progressIndicator()
            : svgIcon(
                name: kHoldIcon,
                color: context.watch<Classroom>().isHolding
                    ? _colorTween.value
                    : Setting.isOnline()
                        ? kTextColorLight
                        : kLocalLabelColor,
                width: kIconWidth),
        text: Text(context.watch<Classroom>().isHolding ? kToUnHold : kToHold,
            style: buttonTextStyle(
              isActive: context.watch<Classroom>().isHolding,
              isVertical: true,
              color: context.watch<Classroom>().isHolding
                  ? _colorTween.value
                  : Setting.isOnline()
                      ? kTextColorLight
                      : kLocalLabelColor,
            ),
            textAlign: TextAlign.center),
        onPressed: () async {
          if (Setting.sessionMode == SessionMode.offline) {
            if (context.read<Classroom>().masterID != kNoMaster &&
                context.read<Classroom>().anyConnected()) {
              context
                  .read<Classroom>()
                  .triggerHold(!context.read<Classroom>().isHolding);
            } else {
              Snackbar.show(context, text: kNoMasterMsg);
            }
          } else {
            context.read<Online>().toggleHoldCommand();
          }
          do {
            _animationController.status == AnimationStatus.completed
                ? await _animationController.reverse()
                : await _animationController.forward();
          } while (context.read<Classroom>().isHolding);
        },
      ),
    );
  }
}
