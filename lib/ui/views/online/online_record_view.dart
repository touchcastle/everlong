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
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/drag_handle.dart';
import 'package:everlong/ui/widgets/actions/rec_start_stop.dart';
import 'package:everlong/ui/views/record/record_container.dart';
import 'package:everlong/ui/views/record/record_list_container.dart';
import 'package:everlong/ui/views/record/record_file.dart';
import 'package:everlong/ui/views/record/record_panel.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/icons.dart';

///View for display list of record file in online session:
///1. record files on cloud.
///2. record files in local.
class OnlineRecordView extends StatefulWidget {
  @override
  State<OnlineRecordView> createState() => _OnlineRecordViewState();
}

class _OnlineRecordViewState extends State<OnlineRecordView> {
  //Height variable for drag-able widget calculation.
  double _initHeight = Setting.onlineRecorderHeight;
  double _start = 0;
  double _changed = 0;

  //drag-able widget to resize recorder's height
  GestureDetector _resizeHandle(
      BuildContext context, double _minHeight, double _maxHeight,
      {required Widget child}) {
    return GestureDetector(
      child: Container(color: Colors.transparent, child: child),
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
            Setting.onlineRecorderHeight = _initHeight + _changed;
          }
        });
      },
      onVerticalDragEnd: (details) {
        _initHeight = Setting.onlineRecorderHeight;
      },
    );
  }

  SizedBox fileSourceLabel(
      {required String icon, required double iconWidth, required String text}) {
    return SizedBox(
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          svgIcon(name: icon, color: kTextColorLight, width: iconWidth),
          SizedBox(width: 10),
          Text(
            text,
            style:
                TextStyle(color: kTextColorLight, fontSize: kDialogSubTextSize),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    ScrollController _controller2 = new ScrollController();
    double _minHeight = MediaQuery.of(context).size.height * 0.4;
    double _maxHeight = MediaQuery.of(context).size.height * 0.5;
    return RecordContainer(
      decoration: kOnlineRecordBoxDecor,
      height: Setting.onlineRecorderHeight,
      // bottomPadding: _bottomPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _resizeHandle(
            context,
            _minHeight,
            _maxHeight,
            child: Column(
              children: [
                DragHandle(height: 15),
                SizedBox(height: 15),
                fileSourceLabel(
                    icon: kCloudIcon, iconWidth: 30, text: 'Cloud Records'),
                SizedBox(height: 5),
              ],
            ),
          ),

          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          //Cloud records
          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          RecordListContainer(
            decoration: kOnlineStoredMidiDecor,
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
              itemCount: context.watch<Online>().recordsList.length,
              itemBuilder: (BuildContext context, int _index) {
                RoomRecords _record =
                    context.watch<Online>().recordsList[_index];
                return RecordFile(
                  cloud: _record,
                  activeLabelColor: Colors.white,
                  inactiveLabelColor: Colors.white,
                  activeBgColor: kGreen3,
                  fileSource: FileSource.online,
                  showDownload: true,
                  showDelete: context.watch<Online>().isRoomHost,
                );
              },
            ),
          ),

          //Separator
          SizedBox(height: 20),

          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          //Local records
          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          fileSourceLabel(icon: kBookIcon, iconWidth: 25, text: 'My Records'),
          SizedBox(height: 5),
          RecordingPanel(),
          RecordListContainer(
            decoration: kOnlineStoredMidiDecor,
            controller: _controller2,
            child: Theme(
              data: ThemeData(canvasColor: kOrange5),
              child: ReorderableListView(
                scrollController: _controller2,
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
                            activeLabelColor: Colors.white,
                            inactiveLabelColor: Colors.white,
                            activeBgColor: kGreen3,
                            fileSource: FileSource.local,
                            showPlay: true,
                            showLoop: true,
                            showRename: true,
                            showDelete: true,
                            showUpload: true,
                          ),
                        ))
                    .toList(),
                onReorder: (oldIndex, newIndex) {
                  context.read<Recorder>().reorderRecord(oldIndex, newIndex);
                },
                // child: ListView.builder(
                //   controller: _controller2,
                //   itemCount: context.watch<Recorder>().storedRecords.length,
                //   itemBuilder: (BuildContext context, int _index) {
                //     RecFile _file = context.watch<Recorder>().storedRecords[_index];
                //     return RecordFile(
                //       file: _file,
                //       onTap: () => context.read<Recorder>().toggleActive(_file),
                //       activeLabelColor: Colors.white,
                //       inactiveLabelColor: Colors.white,
                //       activeBgColor: kGreen3,
                //       fileSource: FileSource.local,
                //       showPlay: true,
                //       showRename: true,
                //       showDelete: true,
                //       showUpload: true,
                //     );
                //   },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
