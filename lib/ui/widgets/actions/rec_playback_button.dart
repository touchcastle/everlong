import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
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
class RecordPlayOrStop extends StatefulWidget {
  final RecFile file;
  final Color? color;
  RecordPlayOrStop({required this.file, this.color});

  @override
  State<RecordPlayOrStop> createState() => _RecordPlayOrStopState();
}

class _RecordPlayOrStopState extends State<RecordPlayOrStop> {
  @override
  Widget build(BuildContext context) {
    bool _isPlaying = widget.file.isPlaying;
    return Button(
      width: 30,
      height: 30,
      isVertical: false,
      isActive: false,
      icon: svgIcon(

          ///TODO: unusable icon
          name: _isPlaying ? kRecStopIcon : kRecPlayIcon,
          color: widget.color,
          width: kIconWidth),
      onPressed: () {
        if (_isPlaying) {
          context.read<Recorder>().playback_stop(widget.file);
          context.read<Classroom>().resetDisplay();
        } else {
          if (!context.read<Classroom>().anyConnected()) {
            Snackbar.show(context, text: kNoConnectedMsg);
          }
          context.read<Recorder>().playback_start(widget.file);
        }
      },
    );
  }
}
