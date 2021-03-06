import 'package:flutter/material.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/actions/rec_playback_button.dart';
import 'package:everlong/ui/widgets/actions/rec_loop.dart';
import 'package:everlong/ui/widgets/actions/rec_del.dart';
import 'package:everlong/ui/widgets/actions/rec_rename.dart';
import 'package:everlong/ui/widgets/actions/rec_upload.dart';
import 'package:everlong/ui/widgets/actions/rec_download.dart';
import 'package:everlong/ui/widgets/actions/rec_del_online.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/sizes.dart';

enum FileSource {
  local,
  online,
}

class RecordFile extends StatelessWidget {
  final double height = 28.0;
  final RecFile? file;
  final Function()? onTap;
  final RoomRecords? cloud;
  final Color activeLabelColor;
  final Color inactiveLabelColor;
  final Color activeBgColor;
  final FileSource fileSource;
  final bool showPlay;
  final bool showLoop;
  final bool showRename;
  final bool showDelete;
  final bool showUpload;
  final bool showDownload;

  RecordFile({
    this.file,
    this.onTap,
    this.cloud,
    required this.activeLabelColor,
    required this.inactiveLabelColor,
    required this.activeBgColor,
    required this.fileSource,
    this.showPlay = false,
    this.showLoop = false,
    this.showRename = false,
    this.showDelete = false,
    this.showUpload = false,
    this.showDownload = false,
  });

  bool isLocalFile() => fileSource == FileSource.local;
  bool isOnlineFile() => fileSource == FileSource.online;
  String fileName() => isLocalFile() ? file!.name : cloud!.name;
  String fileDuration() =>
      isLocalFile() ? file!.totalTimeSecText : cloud!.totalTimeSecText;

  @override
  Widget build(BuildContext context) {
    bool _active = isLocalFile() ? file!.isActive : false;
    Color _activeLabel() => isLocalFile()
        ? _active
            ? activeLabelColor
            : inactiveLabelColor
        : activeLabelColor;
    TextStyle _style = TextStyle(
      color: _activeLabel(),
      fontFamily: kSecondaryFontFamily,
      fontSize: kRecordDetailSize,
      fontWeight: FontWeight.w700,
    );
    return GestureDetector(
      // onTap: () => isLocalFile() ? onTap : null,
      onTap: onTap,
      child: Container(
        height: height,
        color: _active ? activeBgColor : Colors.transparent,
        // color: Colors.red,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: new ScrollController(),
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    fileName(),
                    style: _style,
                  ),
                ),
              ),
              isLocalFile() && _active
                  ? Row(
                      children: [
                        showPlay
                            ? RecordPlayOrStop(
                                file: file!, color: activeLabelColor)
                            : SizedBox.shrink(),
                        showLoop
                            ? RecordLoop(file: file!, color: activeLabelColor)
                            : SizedBox.shrink(),
                        showRename
                            ? RecordRename(
                                fileType: FileType.stored,
                                file: file!,
                                color: activeLabelColor,
                              )
                            : SizedBox.shrink(),
                        showDelete
                            ? RecordDelete(
                                fileType: FileType.stored,
                                id: file!.id,
                                color: activeLabelColor)
                            : SizedBox.shrink(),
                        showUpload
                            ? RecordUpload(file: file!, color: activeLabelColor)
                            : SizedBox.shrink(),
                      ],
                    )
                  : SizedBox.shrink(),
              isOnlineFile()
                  ? Row(
                      children: [
                        showDownload
                            ? RecordDownload(
                                record: cloud!, color: activeLabelColor)
                            : SizedBox.shrink(),
                        showDelete
                            ? RecordDeleteOnline(
                                id: cloud!.id, color: activeLabelColor)
                            : SizedBox.shrink(),
                      ],
                    )
                  : SizedBox.shrink(),
              recordTimer(
                timer: fileDuration(),
                style: _style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///Display record's duration for both recording file and stored files.
SizedBox recordTimer({required String timer, TextStyle? style}) {
  return SizedBox(
    width: 40,
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(timer, style: style),
    ),
  );
}
