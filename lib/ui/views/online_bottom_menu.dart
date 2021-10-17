import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/actions/hold.dart';
import 'package:everlong/ui/widgets/actions/reset.dart';
import 'package:everlong/ui/widgets/actions/device_manager.dart';
import 'package:everlong/ui/widgets/actions/mute.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';

class OnlineBottomMenu extends StatelessWidget {
  final bool isRoomHost;
  OnlineBottomMenu({required this.isRoomHost});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kOnlineAccentColor,
      padding: kBottomPanePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          isRoomHost ? Hold() : SizedBox.shrink(),
          Reset(),
          DeviceManager(),
          isRoomHost ? Mute() : SizedBox.shrink(),
        ],
      ),
    );
  }
}
