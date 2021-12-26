import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/widgets/actions/rec_start_stop.dart';
import 'package:everlong/ui/widgets/actions/rec_playback_button.dart';
import 'package:everlong/ui/widgets/actions/rec_del.dart';
import 'package:everlong/ui/widgets/actions/rec_rename.dart';
import 'package:everlong/ui/widgets/actions/rec_save.dart';
import 'package:everlong/ui/widgets/scroll_text.dart';
import 'package:everlong/ui/widgets/editable_text_field.dart' as editor;
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/ui/views/record_rename.dart';

class LocalRecorder extends StatefulWidget {
  @override
  State<LocalRecorder> createState() => _LocalRecorderState();
}

class _LocalRecorderState extends State<LocalRecorder> {
  //Constant height area.
  final double _bottomPadding = 10;
  final double _handleHeight = 15;
  final double _recorderAreaHeight = 70;
  final double _divider = 5;
  final double _fileAreaHeight = 28.0;

  double _initHeight = Setting.localRecorderHeight;
  // double _height = 200;
  double _start = 0;
  double _changed = 0;

  @override
  Widget build(BuildContext context) {
    RecFile? _currentRecord = context.watch<Recorder>().currentRecord;
    ScrollController _controller = new ScrollController();
    double _minHeight = 200;
    double _maxHeight = MediaQuery.of(context).size.height * 0.45;
    return Container(
      color: Colors.transparent,
      child: Container(
        height: Setting.localRecorderHeight,
        decoration: kLocalRecordBoxDecor,
        padding: EdgeInsets.only(left: 10, right: 10, bottom: _bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: Container(
                height: _handleHeight,
                padding: EdgeInsets.symmetric(horizontal: 0),
                color: Colors.transparent,
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.black12,
                ),
              ),
              onVerticalDragStart: (details) {
                _start = MediaQuery.of(context).size.height -
                    details.globalPosition.dy;
              },
              onVerticalDragUpdate: (details) {
                setState(() {
                  double position = MediaQuery.of(context).size.height -
                      details.globalPosition.dy;
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
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Center(
                      //     child: Text(
                      //         context.watch<Recorder>().recordCountDownText)),
                      RecordButton(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: _recorderAreaHeight,
                    child: _currentRecord != null &&
                            _currentRecord.events.length > 0 &&
                            !context.watch<Recorder>().isRecording
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_currentRecord.name),
                              // editor.EditableText(
                              //     text: _currentRecord.name,
                              //     isEdit: _currentRecord.isEditingName,
                              //     textAlign: TextAlign.center,
                              //     onSubmitted: (text) {
                              //       // _currentRecord.name = text;
                              //       context
                              //           .read<Recorder>()
                              //           .renameRecord(_currentRecord, text);
                              //       context
                              //           .read<Recorder>()
                              //           .toggleRename(_currentRecord);
                              //     }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Text(context.watch<Recorder>().file!.name),
                                  // Text('asd'),
                                  RecordPlayOrStop(file: _currentRecord),
                                  RecordDelete(fileType: FileType.recording),
                                  RecordRename(
                                      fileType: FileType.recording,
                                      file: _currentRecord),
                                  RecordSave(file: _currentRecord),
                                  SizedBox(
                                      width: 40,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            _currentRecord.totalTimeSecText),
                                        // .playbackCountDownText),
                                      )),
                                ],
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Text(
                              context.watch<Recorder>().recordCountDownText,
                              style: RecorderCountdown(),
                            )),
                  ),
                  // SizedBox.shrink(),
                ),
              ],
            ),
            SizedBox(height: _divider),
            // context.watch<Recorder>().storedRecords.length > 0
            //     ?
            LayoutBuilder(
              builder: (context, constraint) {
                return Container(
                  decoration: kLocalStoredMidiDecor,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  height: Setting.localRecorderHeight -
                      (_bottomPadding +
                          _handleHeight +
                          _recorderAreaHeight +
                          _divider),
                  // constraints:
                  //     BoxConstraints(maxHeight: Setting.deviceHeight * 0.13),
                  child: Scrollbar(
                    controller: _controller,
                    // isAlwaysShown: true,
                    child: ListView.builder(
                        controller: _controller,
                        itemCount:
                            context.watch<Recorder>().storedRecords.length,
                        itemBuilder: (BuildContext context, int _index) {
                          RecFile _file =
                              context.watch<Recorder>().storedRecords[_index];
                          bool _active = _file.isActive;
                          return GestureDetector(
                            child: Container(
                              height: _fileAreaHeight,
                              color: _active ? kRed2 : Colors.transparent,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        controller: new ScrollController(),
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          _file.name,
                                          style: TextStyle(
                                              color: _active
                                                  ? _file.isEditingName
                                                      ? Colors.black
                                                      : kYellow4
                                                  : kRed2),
                                        ),
                                      ),
                                    ),
                                    // Text('${_file.name}'),
                                    _active
                                        ? Row(
                                            children: [
                                              RecordPlayOrStop(
                                                  file: _file, color: kYellow4),
                                              RecordRename(
                                                fileType: FileType.stored,
                                                file: _file,
                                                color: kYellow4,
                                              ),
                                              RecordDelete(
                                                  fileType: FileType.stored,
                                                  id: _file.id,
                                                  color: kYellow4),
                                            ],
                                          )
                                        : SizedBox.shrink(),
                                    // _active
                                    //     ? RecordDelete(
                                    //         fileType: FileType.stored,
                                    //         id: _file.id,
                                    //         color: kYellow4)
                                    //     : SizedBox.shrink(),
                                    // _active
                                    //     ? RecordRename(file: _file, color: kYellow4)
                                    //     : SizedBox.shrink(),
                                    SizedBox(
                                        width: 40,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(_file.totalTimeSecText,
                                              style: TextStyle(
                                                  color: _active
                                                      ? kYellow4
                                                      : kRed2)),
                                          // .playbackCountDownText),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              context.read<Recorder>().toggleActive(_file);
                            },
                          );
                        }),
                  ),
                );
              },
            ),
            // : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
