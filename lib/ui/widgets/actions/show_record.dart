import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/texts.dart';

class ShowRecord extends StatefulWidget {
  @override
  _ShowRecordState createState() => _ShowRecordState();
}

class _ShowRecordState extends State<ShowRecord> {
  @override
  Widget build(BuildContext context) {
    bool _isShow = context.watch<Classroom>().showRecorder;
    bool _online2Members() => context.read<Online>().memberCount > 1;
    return Button(
      isActive: _isShow,
      icon: svgIcon(
          name: Setting.isOffline() ? kWaveIcon : kShareIcon,
          color: _isShow
              ? Colors.white
              : Setting.isOnline()
                  ? _online2Members()
                      ? kOnlineInactiveLabel
                      : kOnlineDisabledLabel
                  : kLocalInactiveLabel,
          width: Setting.isOffline() ? kIconWidth : kIconWidth + 10),
      text: Text(Setting.isOffline() ? 'Record' : 'Share',
          style: buttonTextStyle(
              isActive: _isShow,
              isVertical: true,
              color: _isShow
                  ? Colors.white
                  : Setting.isOnline() && !_online2Members()
                      ? kOnlineDisabledLabel
                      : null),
          textAlign: TextAlign.center),
      onPressed: () {
        if (Setting.isOnline() && !_online2Members()) {
          //disabled
          Snackbar.show(
            context,
            text: '$kSharedDisabled',
            icon: kBluetoothIconDisconnected,
            actionLabel: kOk,
          );
        } else {
          context.read<Classroom>().toggleRecordManagerDisplay();
        }
      },
    );
  }
}
