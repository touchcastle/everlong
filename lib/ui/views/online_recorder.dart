import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/rec_start_stop.dart';
import 'package:everlong/ui/widgets/actions/rec_playback_button.dart';
import 'package:everlong/ui/widgets/actions/rec_upload.dart';
import 'package:everlong/ui/widgets/actions/rec_download.dart';
import 'package:everlong/ui/widgets/actions/rec_del.dart';
import 'package:everlong/ui/widgets/actions/rec_del_online.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/actions/rec_rename.dart';
import 'package:everlong/ui/widgets/actions/rec_save.dart';
import 'package:everlong/ui/widgets/editable_text_field.dart' as editor;
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/icons.dart';

class OnlineRecorder extends StatefulWidget {
  @override
  State<OnlineRecorder> createState() => _OnlineRecorderState();
}

class _OnlineRecorderState extends State<OnlineRecorder> {
  final double _fileAreaHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    RecFile? _currentRecord = context.watch<Recorder>().currentRecord;
    ScrollController _controller = new ScrollController();
    return Container(
        decoration: kOnlineRecordBoxDecor,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                svgIcon(name: kCloudIcon, color: kTextColorLight, width: 30),
                SizedBox(width: 10),
                Text(
                  'Cloud Records',
                  style: TextStyle(
                      color: kTextColorLight, fontSize: kDialogSubTextSize),
                ),
              ],
            ),
            SizedBox(height: 5),
            Container(
              decoration: kOnlineStoredMidiDecor,
              padding: EdgeInsets.symmetric(vertical: 8),
              constraints:
                  BoxConstraints(maxHeight: Setting.deviceHeight * 0.13),
              child: Scrollbar(
                controller: _controller,
                child: ListView.builder(
                    controller: _controller,
                    itemCount: context.watch<Online>().recordsList.length,
                    itemBuilder: (BuildContext context, int _index) {
                      RoomRecords _record =
                          context.watch<Online>().recordsList[_index];
                      return Container(
                        height: _fileAreaHeight,
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                _record.name,
                                style: TextStyle(color: Colors.white),
                                // style: TextStyle(
                                //     color: _active
                                //         ? _file.isEditingName
                                //             ? Colors.black
                                //             : Colors.white
                                //         : Colors.white),
                              )),
                              RecordDownload(
                                  record: _record, color: Colors.white),
                              context.watch<Online>().isRoomHost
                                  ? RecordDeleteOnline(
                                      id: _record.id, color: Colors.white)
                                  : SizedBox.shrink(),
                              SizedBox(
                                  width: 40,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(_record.totalTimeSecText,
                                        style: TextStyle(color: Colors.white)),
                                    // .playbackCountDownText),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                svgIcon(name: kBookIcon, color: kTextColorLight, width: 25),
                SizedBox(width: 10),
                Text(
                  'My Records',
                  style: TextStyle(
                      color: kTextColorLight, fontSize: kDialogSubTextSize),
                ),
              ],
            ),
            SizedBox(height: 5),
            // context.watch<Recorder>().storedRecords.length > 0
            //     ?
            Container(
              decoration: kOnlineStoredMidiDecor,
              padding: EdgeInsets.symmetric(vertical: 8),
              constraints:
                  BoxConstraints(maxHeight: Setting.deviceHeight * 0.13),
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
                          height: _fileAreaHeight,
                          color: _active ? kGreen3 : Colors.transparent,
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
                                              : Colors.white
                                          : Colors.white),
                                )),
                                _active
                                    ? Row(
                                        children: [
                                          RecordPlayOrStop(
                                              file: _file, color: Colors.white),
                                          RecordRename(
                                              fileType: FileType.stored,
                                              file: _file,
                                              color: Colors.white),
                                          RecordDelete(
                                              fileType: FileType.stored,
                                              id: _file.id,
                                              color: Colors.white),
                                          RecordUpload(
                                              file: _file, color: Colors.white),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                                SizedBox(
                                    width: 40,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(_file.totalTimeSecText,
                                          style:
                                              TextStyle(color: Colors.white)),
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
        ));
  }
}
