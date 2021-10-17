import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/local.dart';
import 'package:everlong/ui/views/online_lobby.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

enum ButtonType {
  local,
  create,
  join,
}

class MainMenuButton extends StatelessWidget {
  final ButtonType buttonType;
  MainMenuButton({required this.buttonType});

  String _label() => this.buttonType == ButtonType.local
      ? kLocal
      : this.buttonType == ButtonType.create
          ? kOnlineCreate
          : kOnlineJoin;

  String _icon() => this.buttonType == ButtonType.local
      ? kHomeIcon
      : this.buttonType == ButtonType.create
          ? kOnlineIcon
          : kJoinIcon;

  Color _bgColor() =>
      this.buttonType == ButtonType.local ? kOrangeMain : kGreen2;

  LobbyType _lobby() =>
      this.buttonType == ButtonType.create ? LobbyType.create : LobbyType.join;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Button(
            isVertical: false,
            isExpanded: true,
            isTextCenter: true,
            align: MainAxisAlignment.start,
            bgColor: _bgColor(),
            paddingVertical: kMenuVerticalPadding,
            paddingHorizontal: kMenuHorizontalPadding,
            borderRadius: kAllBorderRadius,
            elevation: 3,
            text: Text(
              _label(),
              style: buttonTextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            icon: svgIcon(
              name: _icon(),
              width: kIconWidth2,
              color: buttonLabelColor(color: Colors.white),
            ),
            onPressed: () {
              if (this.buttonType == ButtonType.local) {
                Setting.sessionMode = SessionMode.offline;
                Navigator.of(context).push(PageRouteBuilder(
                    transitionDuration: kTransitionDur,
                    transitionsBuilder: kPageTransition,
                    pageBuilder: (_, __, ___) => LocalPage()));
              } else {
                Setting.sessionMode = SessionMode.online;
                Navigator.of(context).push(PageRouteBuilder(
                    transitionDuration: kTransitionDur,
                    transitionsBuilder: kPageTransition,
                    pageBuilder: (_, __, ___) =>
                        OnlineLobby(lobbyType: _lobby())));
              }
            }),
      ],
    );
  }
}
