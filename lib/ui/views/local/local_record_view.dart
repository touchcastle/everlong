import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/drag_handle.dart';
import 'package:everlong/ui/views/record/record_container.dart';
import 'package:everlong/ui/views/record/record_list_container.dart';
import 'package:everlong/ui/views/record/record_file.dart';
import 'package:everlong/ui/views/record/record_panel.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/icons.dart';

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

  SizedBox fileSourceLabel(
      {required String icon, required double iconWidth, required String text}) {
    return SizedBox(
      height: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          svgIcon(name: icon, color: kRed2, width: iconWidth),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: kRed2, fontSize: kDialogSubTextSize),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    double _minHeight = MediaQuery.of(context).size.height * 0.3;
    double _maxHeight = MediaQuery.of(context).size.height * 0.45;
    return RecordContainer(
      decoration: kLocalRecordBoxDecor,
      height: Setting.localRecorderHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          resizeHandle(context, _minHeight, _maxHeight),
          SizedBox(height: 15),
          fileSourceLabel(icon: kBookIcon, iconWidth: 25, text: 'My Records'),
          SizedBox(height: 5),
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
                            showLoop: true,
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
