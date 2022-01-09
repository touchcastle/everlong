import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/widgets/progress_indicator.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/confirm.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

class RecordDelete extends StatelessWidget {
  final FileType fileType;
  final String? id;
  final Color? color;
  RecordDelete({required this.fileType, this.id, this.color});

  @override
  Widget build(BuildContext context) {
    return Button(
      width: 30,
      height: 30,
      isVertical: false,
      isActive: false,
      icon: svgIcon(name: kRecDelIcon, color: color, width: kIconWidth),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => dialogBox(
            smallerDialog: true,
            context: context,
            content: confirmDialog(
              context,
              icon: kRecDelIcon,
              detail: 'Are you sure you want to delete record?',
              onConfirm: () async {
                if (fileType == FileType.recording) {
                  context.read<Recorder>().clear();
                } else if (fileType == FileType.stored) {
                  context.read<Recorder>().deleteRecord(id!);
                }
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
