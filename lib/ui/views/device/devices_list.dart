import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/device/device_box.dart';
import 'package:everlong/utils/styles.dart';

class DeviceAnimatedList extends StatefulWidget {
  @override
  State<DeviceAnimatedList> createState() => _DeviceAnimatedListState();
}

class _DeviceAnimatedListState extends State<DeviceAnimatedList> {
  // @override
  // void initState() {
  //   _controller = ScrollController();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    return ShaderMask(
      //Shade at top&bottom of screen.
      shaderCallback: (Rect rect) => kListBorderGradient.createShader(rect),
      blendMode: BlendMode.dstOut,
      child: Padding(
        padding: kDevicesAreaPadding,
        child: Scrollbar(
          controller: _controller,
          child: AnimatedList(
            controller: _controller,
            key: context.watch<ListAnimation>().animateListKey,
            initialItemCount: context.read<Classroom>().bluetoothDevices.length,
            itemBuilder: (context, index, animation) {
              BLEDevice device =
                  context.watch<Classroom>().bluetoothDevices[index];
              return SizeTransition(
                  key: ValueKey(device.id()),
                  sizeFactor: animation,
                  child: DeviceBox(device));
              // child: DeviceBox(device));
            },
          ),
        ),
      ),
    );
  }
}
