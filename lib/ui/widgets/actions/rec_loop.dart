import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';

class RecordLoop extends StatefulWidget {
  final RecFile file;
  final Color? color;
  RecordLoop({required this.file, this.color});

  @override
  State<RecordLoop> createState() => _RecordLoopState();
}

class _RecordLoopState extends State<RecordLoop> {
  @override
  Widget build(BuildContext context) {
    return Button(
      width: 30,
      height: 30,
      isVertical: false,
      isActive: false,
      icon: svgIcon(
        name: kRecLoopIcon,
        color: widget.file.isLoop ? widget.color : Colors.white38,
        width: kIconWidth,
      ),
      onPressed: () {
        // setState(() => widget.file.toggleLoop());
        context.read<Recorder>().toggleLoop(widget.file);
      },
    );
  }
}
