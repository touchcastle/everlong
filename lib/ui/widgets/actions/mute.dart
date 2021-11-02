import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

class Mute extends StatefulWidget {
  @override
  _MuteState createState() => _MuteState();
}

class _MuteState extends State<Mute> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: kPingColorTweenSlowDuration);
    _colorTween = kOnlineColorTween.animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isMute = context.watch<Online>().isMute;
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Button(
        isActive: _isMute,
        icon: svgIcon(
            name: kSoundIcon,
            color: _isMute
                ? _colorTween.value
                : Setting.isOnline()
                    ? kTextColorLight
                    : kTextColorRed,
            width: kIconWidth),
        text: Text(_isMute ? kUnmute : kMute,
            style: buttonTextStyle(
              isActive: _isMute,
              isVertical: true,
              color: _isMute
                  ? _colorTween.value
                  : Setting.isOnline()
                      ? kTextColorLight
                      : kTextColorRed,
            ),
            textAlign: TextAlign.center),
        onPressed: () async {
          await context.read<Online>().toggleRoomMute();
          do {
            _animationController.status == AnimationStatus.completed
                ? await _animationController.reverse()
                : await _animationController.forward();
          } while (context.read<Online>().isMute);
        },
      ),
    );
  }
}
