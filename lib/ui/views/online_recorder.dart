import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
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
  //Constant height area.
  final double _bottomPadding = 10;
  final double _handleHeight = 15;
  final double _labelHeight = 25;
  final double _divider = 5;
  final double _divider2 = 15;
  final double _fileAreaHeight = 28.0;

  double _initHeight = Setting.onlineRecorderHeight;
  // double _height = 350;
  double _start = 0;
  double _changed = 0;

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    ScrollController _controller2 = new ScrollController();
    // double _minHeight = 350;
    double _minHeight = MediaQuery.of(context).size.height * 0.3;
    double _maxHeight = MediaQuery.of(context).size.height * 0.5;
    return Container(
      color: Colors.transparent,
      child: Container(
          decoration: kOnlineRecordBoxDecor,
          padding: EdgeInsets.only(left: 10, right: 10, bottom: _bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Setting.onlineRecorderHeight = _initHeight + _changed;
                    }
                  });
                },
                onVerticalDragEnd: (details) {
                  _initHeight = Setting.onlineRecorderHeight;
                },
              ),
              SizedBox(height: _divider2),
              SizedBox(
                height: _labelHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    svgIcon(
                        name: kCloudIcon, color: kTextColorLight, width: 30),
                    SizedBox(width: 10),
                    Text(
                      'Cloud Records',
                      style: TextStyle(
                          color: kTextColorLight, fontSize: kDialogSubTextSize),
                    ),
                  ],
                ),
              ),
              SizedBox(height: _divider),
              Container(
                decoration: kOnlineStoredMidiDecor,
                padding: EdgeInsets.symmetric(vertical: 8),
                height: (Setting.onlineRecorderHeight -
                        (_bottomPadding +
                            _handleHeight +
                            (_labelHeight * 2) +
                            (_divider * 2) +
                            (_divider2 * 2))) /
                    2,
                // constraints:
                //     BoxConstraints(maxHeight: Setting.deviceHeight * 0.13),
                child: Scrollbar(
                  // isAlwaysShown: true,
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
                                          style:
                                              TextStyle(color: Colors.white)),
                                      // .playbackCountDownText),
                                    )),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
              SizedBox(height: _divider2),
              SizedBox(
                height: _labelHeight,
                child: Row(
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
              ),
              SizedBox(height: _divider),
              // context.watch<Recorder>().storedRecords.length > 0
              //     ?
              Container(
                decoration: kOnlineStoredMidiDecor,
                padding: EdgeInsets.symmetric(vertical: 8),
                height: (Setting.onlineRecorderHeight -
                        (_bottomPadding +
                            _handleHeight +
                            (_labelHeight * 2) +
                            (_divider * 2) +
                            (_divider2 * 2))) /
                    2,
                // constraints:
                //     BoxConstraints(maxHeight: Setting.deviceHeight * 0.13),
                child: Scrollbar(
                  // isAlwaysShown: true,
                  controller: _controller,
                  child: ListView.builder(
                      controller: _controller2,
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
                                                file: _file,
                                                color: Colors.white),
                                            RecordRename(
                                                fileType: FileType.stored,
                                                file: _file,
                                                color: Colors.white),
                                            RecordDelete(
                                                fileType: FileType.stored,
                                                id: _file.id,
                                                color: Colors.white),
                                            RecordUpload(
                                                file: _file,
                                                color: Colors.white),
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
          )),
    );
  }
}
