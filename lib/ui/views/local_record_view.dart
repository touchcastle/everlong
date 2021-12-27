import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/drag_handle.dart';
import 'package:everlong/ui/widgets/actions/rec_start_stop.dart';
import 'package:everlong/ui/widgets/actions/rec_playback_button.dart';
import 'package:everlong/ui/widgets/actions/rec_del.dart';
import 'package:everlong/ui/widgets/actions/rec_rename.dart';
import 'package:everlong/ui/widgets/actions/rec_save.dart';
import 'package:everlong/ui/widgets/records/record_container.dart';
import 'package:everlong/ui/widgets/records/record_list_container.dart';
import 'package:everlong/ui/widgets/records/record_file.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

///View for display recorder and list of record file on local session.
class LocalRecordView extends StatefulWidget {
  @override
  State<LocalRecordView> createState() => _LocalRecordViewState();
}

class _LocalRecordViewState extends State<LocalRecordView> {
  //Constant height
  final double _bottomPadding = 10;
  final double _handleHeight = 15;
  final double _recorderAreaHeight = 70;
  final double _divider = 5;

  //Height variable for drag-able widget calculation.
  double _initHeight = Setting.localRecorderHeight;
  double _start = 0;
  double _changed = 0;

  //drag-able widget to resize recorder's height
  GestureDetector resizeHandle(
      BuildContext context, double _minHeight, double _maxHeight) {
    return GestureDetector(
      child: DragHandle(height: _handleHeight),
      onVerticalDragStart: (details) {
        _start = MediaQuery.of(context).size.height - details.globalPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          double position =
              MediaQuery.of(context).size.height - details.globalPosition.dy;
          _changed = position - _start;
          if (_initHeight + _changed >= _minHeight &&
              _initHeight + _changed <= _maxHeight) {
            Setting.localRecorderHeight = _initHeight + _changed;
          }
        });
      },
      onVerticalDragEnd: (details) {
        _initHeight = Setting.localRecorderHeight;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    double _minHeight = 200;
    double _maxHeight = MediaQuery.of(context).size.height * 0.45;
    return RecordContainer(
      decoration: kLocalRecordBoxDecor,
      // maxHeight: _maxHeight,
      // minHeight: _minHeight,
      height: Setting.localRecorderHeight,
      bottomPadding: _bottomPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          resizeHandle(context, _minHeight, _maxHeight),
          RecordingPanel(height: _recorderAreaHeight),
          SizedBox(height: _divider),
          RecordListContainer(
            decoration: kLocalStoredMidiDecor,
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
              itemCount: context.watch<Recorder>().storedRecords.length,
              itemBuilder: (BuildContext context, int _index) {
                RecFile _file = context.watch<Recorder>().storedRecords[_index];
                return RecordFile(
                  file: _file,
                  onTap: () => context.read<Recorder>().toggleActive(_file),
                  activeLabelColor: kYellow4,
                  inactiveLabelColor: kRed2,
                  activeBgColor: kRed2,
                  fileSource: FileSource.local,
                  showPlay: true,
                  showRename: true,
                  showDelete: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
///Recording panel widget.
///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class RecordingPanel extends StatelessWidget {
  final double height;
  RecordingPanel({required this.height});

  //Countdown timer while recording
  Center timer(String _timer) =>
      Center(child: Text(_timer, style: kRecorderCountdown));

  @override
  Widget build(BuildContext context) {
    RecFile? _currentRecord = context.watch<Recorder>().currentRecord;
    String _timer = context.watch<Recorder>().recordingTimerText;
    return Row(
      children: [
        Expanded(flex: 2, child: RecordButton()),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: height,
            child: _currentRecord != null &&
                    _currentRecord.events.length > 0 &&
                    !context.watch<Recorder>().isRecording
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentRecord.name),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RecordPlayOrStop(file: _currentRecord),
                          RecordDelete(fileType: FileType.recording),
                          RecordRename(
                              fileType: FileType.recording,
                              file: _currentRecord),
                          RecordSave(file: _currentRecord),
                          recordTimer(timer: _currentRecord.totalTimeSecText),
                        ],
                      ),
                    ],
                  )
                : timer(_timer),
          ),
        ),
      ],
    );
  }
}
