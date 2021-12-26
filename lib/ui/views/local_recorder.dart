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

class _LocalRecorderState extends State<LocalRecorder>
    with SingleTickerProviderStateMixin {
  // late AnimationController _controller;
  // late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    localRecorderController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
    );
    localRecorderOffset = Tween<Offset>(begin: Offset(0.0, 1.5), end: Offset.zero)
    .animate(localRecorderController);
    // recorderController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 200),
    // );
    // context.read<Classroom>().listenShow();
    // recorderController.forward();
    // recorderController.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
    // recorderController.reverse();
    // recorderController.addListener(() {
    //   setState(() {
    //     print(recorderController.value);
    //   });
    // });
    // recorderController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RecFile? _currentRecord = context.watch<Recorder>().currentRecord;
    ScrollController _controller = new ScrollController();
    return Container(
      // height: 250 ,
      decoration: kLocalRecordBoxDecor,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
                                RecordRename(
                                    fileType: FileType.recording,
                                    file: _currentRecord),
                                RecordSave(file: _currentRecord),
                                SizedBox(
                                    width: 40,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child:
                                          Text(_currentRecord.totalTimeSecText),
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
          SizedBox(height: 5),
          // context.watch<Recorder>().storedRecords.length > 0
          //     ?
          Container(
            decoration: kLocalStoredMidiDecor,
            padding: EdgeInsets.symmetric(vertical: 8),
            constraints: BoxConstraints(maxHeight: Setting.deviceHeight * 0.13),
            child: Scrollbar(
              controller: _controller,
              child: ListView.builder(
                  controller: _controller,
                  itemCount: context.watch<Recorder>().storedRecords.length,
                  itemBuilder: (BuildContext context, int _index) {
                    RecFile _file =
                        context.watch<Recorder>().storedRecords[_index];
                    bool _active = _file.isActive;
                    return GestureDetector(
                      child: Container(
                        height: 28,
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
                                            color: _active ? kYellow4 : kRed2)),
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
          ),
          // : SizedBox.shrink(),
        ],
      ),
    );
  }
}
