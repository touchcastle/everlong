import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/widgets/progress_indicator.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

/// Generate hold button.
class RecordButton extends StatefulWidget {
  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  @override
  Widget build(BuildContext context) {
    bool _isRecording = context.watch<Recorder>().isRecording;
    return Button(
      isVertical: false,
      isActive: false,
      icon: svgIcon(

          ///TODO: unusable icon
          name: _isRecording ? kRecStopIcon : kRecStartIcon,
          // color: _isShow
          //     ? Colors.white
          //     : Setting.isOnline()
          //         ? kTextColorLight
          //         : kLocalLabelColor,
          width: kIconWidth),
      onPressed: () {
        if (_isRecording) {
          print('stop rec');
          context.read<Recorder>().stop();
        } else {
          print('start rec');
          context.read<Recorder>().start();
        }
      },
    );
  }
}
