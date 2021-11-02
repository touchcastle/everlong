import 'package:flutter/material.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

class ToOnlineRoom extends StatelessWidget {
  final LobbyType inType;
  final Function() onPressed;

  ///Dynamic lobby for both create/join session.
  ToOnlineRoom({
    ///Between create/join.
    required this.inType,

    ///Function when pressed button.
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Button(
            isExpanded: true,
            isVertical: false,
            paddingVertical: kMenuVerticalPadding,
            borderRadius: kBottom,
            text: Text(
              inType == LobbyType.join ? kJoin : kCreate,
              style: buttonTextStyle(isDialogButton: true),
              textAlign: TextAlign.center,
            ),
            icon: svgIcon(
                name: inType == LobbyType.join ? kJoinIcon : kOnlineIcon,
                width: kIconWidth,
                color: buttonLabelColor()),
            onPressed: onPressed),
      ],
    );
  }
}
