import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return Container(
        decoration: kDeviceFxDecor,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text(context.watch<Recorder>().recordCountDownText)),
            RecordButton(),
            SizedBox(
              height: 30,
              child: _currentRecord != null &&
                      _currentRecord.events.length > 0 &&
                      !context.watch<Recorder>().isRecording
                  ? Row(
                      children: [
                        Expanded(
                          child: editor.EditableText(
                              text: _currentRecord.name,
                              isEdit: context
                                  .watch<Recorder>()
                                  .currentRecord!
                                  .isEditingName,
                              onSubmitted: (text) {
                                _currentRecord.name = text;
                                context
                                    .read<Recorder>()
                                    .toggleRename(_currentRecord);
                              }),
                        ),
                        // Text(context.watch<Recorder>().file!.name),
                        // Text('asd'),
                        RecordPlayOrStop(file: _currentRecord),
                        RecordDelete(),
                        RecordRename(file: _currentRecord),
                        RecordSave(),
                        SizedBox(
                            width: 40,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(context
                                  .watch<Recorder>()
                                  .playbackCountDownText),
                            )),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ));
  }
}
