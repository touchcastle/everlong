import 'package:flutter/material.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/ui/widgets/device/device_metadata.dart';
import 'package:everlong/ui/widgets/actions/rename.dart';
import 'package:everlong/ui/widgets/actions/host.dart';
import 'package:everlong/ui/widgets/actions/ping.dart';
import 'package:everlong/utils/styles.dart';

class DeviceDetail extends StatelessWidget {
  final BLEDevice device;
  DeviceDetail(this.device);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kDeviceFxDecor,
      child: Padding(
        padding: kDeviceFunctionPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DeviceMetadata(id: device.id(), name: device.device.name),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Rename(device: device),
                Host(device: device),
                Ping(device: device)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
