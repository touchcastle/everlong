import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/widgets/actions/rec_start_stop.dart';
import 'package:everlong/utils/styles.dart';

///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
///Recording panel widget.
///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class RecordingPanel extends StatelessWidget {
  //Countdown timer display during recording
  Center timer(String _timer) =>
      Center(child: Text(_timer, style: kRecorderCountdown()));

  @override
  Widget build(BuildContext context) {
    // RecFile? _currentRecord = context.watch<Recorder>().currentRecord;
    String _recordingDuration = context.watch<Recorder>().recordingTimerText;

    //True when has recorded file pending for save.
    // bool _hasRecorded() =>
    //     _currentRecord != null &&
    //     _currentRecord.events.length > 0 &&
    //     !context.watch<Recorder>().isRecording;

    return Row(
      children: [
        Expanded(flex: 2, child: RecordButton()),
        Expanded(
          flex: 3,
          child: SizedBox(
            // height: 60,
            child:
                // _hasRecorded()
                // ? Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(_currentRecord!.name),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           RecordPlayOrStop(file: _currentRecord),
                //           RecordDelete(fileType: FileType.recording),
                //           RecordRename(
                //               fileType: FileType.recording,
                //               file: _currentRecord),
                //           RecordSave(file: _currentRecord),
                //           recordTimer(timer: _currentRecord.totalTimeSecText),
                //         ],
                //       ),
                //     ],
                //   )
                // :
                timer(_recordingDuration),
          ),
        ),
      ],
    );
  }
}
