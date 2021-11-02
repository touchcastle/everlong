import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';

/// Generate reset button.
class Reset extends StatefulWidget {
  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Reset> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    super.initState();
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isResetting = context.watch<Classroom>().isResetting;
    return Button(
      isActive: _isResetting,
      icon: RotationTransition(
          turns: _iconTurns,
          child: svgIcon(
              name: kResetIcon,
              color: buttonLabelColor(isActive: _isResetting),
              width: kIconWidth - 3)),
      text: Text(
        _isResetting ? kResetting : kResetLight,
        style: buttonTextStyle(isActive: _isResetting, isVertical: true),
        textAlign: TextAlign.center,
      ),
      onPressed: () async {
        _controller.repeat();
        bool _foundChild = await context.read<Classroom>().resetKeyLight();
        _controller.reset();
        if (!_foundChild && !Setting.isOnline()) {
          Snackbar.show(context, text: kNoChildMsg);
        }
      },
    );
  }
}
