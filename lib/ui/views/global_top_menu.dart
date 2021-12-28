import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/views/online/confirm_exit.dart';
import 'package:everlong/ui/views/online/online_room_detail.dart';
import 'package:everlong/ui/widgets/actions/exit.dart';
import 'package:everlong/ui/widgets/actions/setting.dart' as SettingButton;
import 'package:everlong/ui/widgets/actions/show_list.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

class GlobalTopMenu extends StatelessWidget {
  ///Empty area
  final SizedBox _empty = SizedBox.shrink();

  ///Handle when user press exit button from Local / Online session.
  void _onExit(BuildContext context) async {
    if (Setting.isOnline()) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => dialogBox(
          smallerDialog: true,
          context: context,
          content: confirmExitDialog(context, onExit: () async {
            await context
                .read<Online>()
                .roomExit(context.read<Online>().roomID);
            context.read<Classroom>().resetClass();
            context.read<Classroom>().showRecorder = false;

            //Pop back to main menu page.
            Navigator.popUntil(context, ModalRoute.withName(kMainPageName));
          }),
        ),
      );
    } else {
      await context.read<Classroom>().cancelAllMaster();
      context.read<Recorder>().playbackStopAll();
      context.read<Classroom>().showRecorder = false;
      Navigator.pop(context);
    }
  }

  ///Session information and share button.
  Expanded _sessionInfoAndSharing(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: RoomInfoAndShare(
            name: context.watch<Online>().myRoomName,
            id: context.read<Online>().roomID,
            isHost: context.watch<Online>().isRoomHost,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Setting.isOnline() ? kOnlineAccentColor : kLocalAccentColor,
      padding: kTopPanePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Exit(onPressed: () => _onExit(context)),
              Setting.isOnline() ? _empty : SettingButton.Setting(),
              ShowList()
            ],
          ),
          Setting.isOnline() ? _sessionInfoAndSharing(context) : _empty,
        ],
      ),
    );
  }
}
