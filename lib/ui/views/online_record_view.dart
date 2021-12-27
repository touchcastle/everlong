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
import 'package:everlong/ui/widgets/records/record_container.dart';
import 'package:everlong/ui/widgets/records/record_list_container.dart';
import 'package:everlong/ui/widgets/records/record_file.dart';
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
  //Constant height
  final double _bottomPadding = 10;
  final double _handleHeight = 15;
  final double _labelHeight = 25;
  final double _divider = 5;
  final double _divider2 = 15;

  //Height variable for drag-able widget calculation.
  double _initHeight = Setting.onlineRecorderHeight;
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
      height: _labelHeight,
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
    double _minHeight = MediaQuery.of(context).size.height * 0.3;
    double _maxHeight = MediaQuery.of(context).size.height * 0.5;
    return RecordContainer(
      decoration: kOnlineRecordBoxDecor,
      height: Setting.onlineRecorderHeight,
      bottomPadding: _bottomPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          resizeHandle(context, _minHeight, _maxHeight),
          SizedBox(height: _divider2),

          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          //Cloud records
          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          fileSourceLabel(
              icon: kCloudIcon, iconWidth: 30, text: 'Cloud Records'),
          SizedBox(height: _divider),
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
          SizedBox(height: _divider2),

          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          //Local records
          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
          fileSourceLabel(icon: kBookIcon, iconWidth: 25, text: 'My Records'),
          SizedBox(height: _divider),
          RecordListContainer(
            decoration: kOnlineStoredMidiDecor,
            controller: _controller2,
            child: ListView.builder(
              controller: _controller2,
              itemCount: context.watch<Recorder>().storedRecords.length,
              itemBuilder: (BuildContext context, int _index) {
                RecFile _file = context.watch<Recorder>().storedRecords[_index];
                return RecordFile(
                  file: _file,
                  onTap: () => context.read<Recorder>().toggleActive(_file),
                  activeLabelColor: Colors.white,
                  inactiveLabelColor: Colors.white,
                  activeBgColor: kGreen3,
                  fileSource: FileSource.local,
                  showPlay: true,
                  showRename: true,
                  showDelete: true,
                  showUpload: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
