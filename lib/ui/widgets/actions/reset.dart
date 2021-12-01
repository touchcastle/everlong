import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/views/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

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
        if (context.read<Classroom>().countChild() > 0) {
          if (Setting.isOffline()) {
            Future.delayed(
                Duration(milliseconds: 500),
                () => Snackbar.show(
                      context,
                      text: kLightFreeze,
                      fullWidth: true,
                      bgColor: kGreen4,
                      actionLabel: kToSetting,
                      action: () async {
                        context.read<Classroom>().toggleShowingSetting(true);
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => dialogBox(
                            context: context,
                            content: settingDialog(context),
                          ),
                        );
                        context.read<Classroom>().toggleShowingSetting(false);
                      },
                    ));
          }
          _controller.repeat();
          if (context.read<Online>().isRoomHost) {
            context.read<Online>().toggleResetCommand();
          }
          await context.read<Classroom>().resetKeyLight();
          context.read<Classroom>().resetDisplay();
          _controller.reset();
        } else {
          Snackbar.show(context, text: kNoChildMsg);
        }
      },
    );
  }
}
