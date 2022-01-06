import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/actions/hold.dart';
import 'package:everlong/ui/widgets/actions/reset.dart';
import 'package:everlong/ui/widgets/actions/device_manager.dart';
import 'package:everlong/ui/widgets/actions/mute.dart';
import 'package:everlong/ui/widgets/actions/show_record.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';

/// Will show "SHARE" button only when there are at least 2 members in session.
class OnlineBottomMenu extends StatelessWidget {
  final bool isRoomHost;
  OnlineBottomMenu({required this.isRoomHost});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kOnlineAccentColor,
      padding: kBottomPanePadding,
      height: kBottomActionWidth,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isRoomHost ? Hold() : SizedBox.shrink(),
              Reset(),
              DeviceManager(),
              isRoomHost ? Mute() : SizedBox.shrink(),
              ShowRecord(),
              // context.watch<Online>().memberCount > 1
              //     ? ShowRecord()
              //     : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
