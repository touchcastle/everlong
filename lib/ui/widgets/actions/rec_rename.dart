import 'package:flutter/material.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/views/record/record_rename.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/icons.dart';

/// Generate hold button.
class RecordRename extends StatelessWidget {
  final FileType fileType;
  final RecFile file;
  final Color? color;
  RecordRename({required this.fileType, required this.file, this.color});
  @override
  Widget build(BuildContext context) {
    return Button(
      width: 30,
      height: 30,
      isVertical: false,
      isActive: false,
      icon: svgIcon(

          ///TODO: unusable icon
          name: kRecRenameIcon,
          color: color,
          width: kIconWidth),
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) => dialogBox(
            context: context,
            content: RecordRenameDialog(fileType: fileType, file: file),
          ),
        );
      },
    );
  }
}
