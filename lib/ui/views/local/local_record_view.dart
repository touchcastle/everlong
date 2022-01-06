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
import 'package:everlong/ui/views/record/record_container.dart';
import 'package:everlong/ui/views/record/record_list_container.dart';
import 'package:everlong/ui/views/record/record_file.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/sizes.dart';

///View for display recorder and list of record file on local session.
class LocalRecordView extends StatefulWidget {
  @override
  State<LocalRecordView> createState() => _LocalRecordViewState();
}

class _LocalRecordViewState extends State<LocalRecordView> {
  //Height variable for drag-able widget calculation.
  double _initHeight = Setting.localRecorderHeight;
  double _start = 0;
  double _changed = 0;

  //drag-able widget to resize recorder's height
  GestureDetector resizeHandle(
      BuildContext context, double _minHeight, double _maxHeight) {
    return GestureDetector(
      child: DragHandle(height: 15),
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
    double _minHeight = MediaQuery.of(context).size.height * 0.2;
    double _maxHeight = MediaQuery.of(context).size.height * 0.45;
    return RecordContainer(
      decoration: kLocalRecordBoxDecor,
      height: Setting.localRecorderHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          resizeHandle(context, _minHeight, _maxHeight),
          RecordingPanel(),
          SizedBox(height: 5),
          RecordListContainer(
            decoration: kLocalStoredMidiDecor,
            controller: _controller,
            child: Theme(
              data: ThemeData(canvasColor: kOrange5),
              child: ReorderableListView(
                scrollController: _controller,
                padding: EdgeInsets.all(0),
                itemExtent: 28,
                children: context
                    .watch<Recorder>()
                    .storedRecords
                    .map((RecFile _file) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.all(0),
                          visualDensity:
                              VisualDensity(horizontal: 0, vertical: -4),
                          key: GlobalKey(),
                          title: RecordFile(
                            file: _file,
                            onTap: () =>
                                context.read<Recorder>().toggleActive(_file),
                            activeLabelColor: kYellow4,
                            inactiveLabelColor: kRed2,
                            activeBgColor: kRed2,
                            fileSource: FileSource.local,
                            showPlay: true,
                            showRename: true,
                            showDelete: true,
                          ),
                        ))
                    .toList(),
                onReorder: (oldIndex, newIndex) {
                  context.read<Recorder>().reorderRecord(oldIndex, newIndex);
                },
                // child: ListView.builder(
                // controller: _controller,
                // itemCount: context.watch<Recorder>().storedRecords.length,
                // itemBuilder: (BuildContext context, int _index) {
                //   RecFile _file = context.watch<Recorder>().storedRecords[_index];
                //   return RecordFile(
                //     file: _file,
                //     onTap: () => context.read<Recorder>().toggleActive(_file),
                //     activeLabelColor: kYellow4,
                //     inactiveLabelColor: kRed2,
                //     activeBgColor: kRed2,
                //     fileSource: FileSource.local,
                //     showPlay: true,
                //     showRename: true,
                //     showDelete: true,
                //   );
                // },
              ),
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
  //Countdown timer display during recording
  Center timer(String _timer) =>
      Center(child: Text(_timer, style: kRecorderCountdown));

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
            height: 70,
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
