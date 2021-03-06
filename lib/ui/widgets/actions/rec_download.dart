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

class RecordDownload extends StatelessWidget {
  final RoomRecords record;
  final Color? color;
  RecordDownload({required this.record, this.color});

  @override
  Widget build(BuildContext context) {
    return Button(
      width: 30,
      height: 30,
      isVertical: false,
      isActive: false,
      icon: svgIcon(name: kDownloadIcon, color: color, width: kIconWidth),
      onPressed: () {
        String _result =
            context.read<Recorder>().downloadSharedRecord(record.data);
        Snackbar.show(context, text: _result, type: MessageType.info);
      },
    );
  }
}
