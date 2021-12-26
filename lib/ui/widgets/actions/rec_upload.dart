import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/ui/widgets/progress_indicator.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

class RecordUpload extends StatelessWidget {
  final RecFile file;
  final Color? color;
  RecordUpload({required this.file, this.color});

  @override
  Widget build(BuildContext context) {
    return Button(
      width: 30,
      height: 30,
      isVertical: false,
      isActive: false,
      icon: svgIcon(name: kUploadIcon, color: color, width: kIconWidth),
      onPressed: () {
        context.read<Online>().uploadRecord(
              recordID: file.id,
              recordName: file.name,
              totalTimeSecText: file.totalTimeSecText,
              data: context.read<Recorder>().fileToString(file),
            );
      },
    );
  }
}
