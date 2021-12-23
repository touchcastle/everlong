import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/widgets/actions/rec_start_stop.dart';
import 'package:everlong/ui/widgets/actions/rec_playback_button.dart';
import 'package:everlong/ui/widgets/actions/rec_del.dart';
import 'package:everlong/ui/widgets/actions/rec_rename.dart';
import 'package:everlong/ui/widgets/actions/rec_save.dart';
import 'package:everlong/ui/widgets/editable_text_field.dart' as editor;
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

class LocalRecorder extends StatefulWidget {
  @override
  State<LocalRecorder> createState() => _LocalRecorderState();
}

class _LocalRecorderState extends State<LocalRecorder> {
  @override
  Widget build(BuildContext context) {
    RecFile? _currentRecord = context.watch<Recorder>().currentRecord;
    ScrollController _controller = new ScrollController();
    return Container(
        decoration: kDeviceFxDecor,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    height: 70,
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
                                  RecordRename(file: _currentRecord),
                                  RecordSave(),
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
                              style: dialogHeader(color: kRed2),
                            )),
                  ),
                  // SizedBox.shrink(),
                ),
              ],
            ),
            SizedBox(height: 8),
            context.watch<Recorder>().storedRecords.length > 0
                ? Container(
                    decoration: kStoredMidiDecor,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    height: 150,
                    child: Scrollbar(
                      controller: _controller,
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
                                height: 30,
                                color: _active ? kRed2 : Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        _file.name,
                                        style: TextStyle(
                                            color: _active
                                                ? _file.isEditingName
                                                    ? Colors.black
                                                    : kYellow4
                                                : kRed2),
                                      )
                                          // editor.EditableText(
                                          //     text: _file.name,
                                          //     isEdit: _file.isEditingName,
                                          //     textStyle: TextStyle(
                                          //         color: _active
                                          //             ? _file.isEditingName
                                          //                 ? Colors.black
                                          //                 : kYellow4
                                          //             : kRed2),
                                          //     onSubmitted: (text) {
                                          //       // _currentRecord.name = text;
                                          //       context
                                          //           .read<Recorder>()
                                          //           .renameRecord(_file, text);
                                          //       context
                                          //           .read<Recorder>()
                                          //           .toggleRename(_file);
                                          //     }),
                                          ),
                                      // Text('${_file.name}'),
                                      _active
                                          ? RecordPlayOrStop(
                                              file: _file, color: kYellow4)
                                          : SizedBox.shrink(),
                                      _active
                                          ? RecordDelete(
                                              fileType: FileType.stored,
                                              id: _file.id,
                                              color: kYellow4)
                                          : SizedBox.shrink(),
                                      _active
                                          ? RecordRename(
                                              file: _file, color: kYellow4)
                                          : SizedBox.shrink(),
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
                  )
                : SizedBox.shrink(),
          ],
        ));
  }
}
