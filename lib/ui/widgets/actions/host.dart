import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';

class Host extends StatelessWidget {
  Host({required this.device});
  final BLEDevice device;

  @override
  Widget build(BuildContext context) {
    return Button(
        icon: svgIcon(
          name: kHostIcon,
          color: device.isMaster ? kOrangeMain : kGreenMain,
        ),
        onPressed: () async {
          await context.read<Classroom>().setMaster(device);
        });
  }
}
