import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/ui/views/device/device_title.dart';
import 'package:everlong/ui/views/device/device_detail.dart';
import 'package:everlong/ui/widgets/extended/custom_expansion_tile.dart';
import 'package:everlong/utils/styles.dart';

class DeviceBox extends StatefulWidget {
  final BLEDevice device;
  final bool enableFunction;
  DeviceBox(this.device, {this.enableFunction = true});

  @override
  _DeviceBoxState createState() => _DeviceBoxState();
}

class _DeviceBoxState extends State<DeviceBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kDeviceBoxOuterPadding,
      child: StreamBuilder<BluetoothDeviceState>(
        stream: widget.device.device.state,
        initialData: widget.device.lastKnownState,
        builder: (c, state) {
          bool _isConnected() => state.data == BluetoothDeviceState.connected;
          if (_isConnected() &&
              widget.device.isConnected() &&
              widget.enableFunction) {
            return Container(
              decoration: kBoxDecor,
              child: SelfExpansionTile(
                title: DeviceTitle(widget.device, _isConnected()),
                children: [DeviceDetail(widget.device)],
                initiallyExpanded: widget.device.isExpanding,
                onExpansionChanged: (_exp) =>
                    setState(() => widget.device.isExpanding = _exp),
              ),
            );
          } else {
            return Container(
              decoration: kBoxDecor,
              child: ListTile(
                title: DeviceTitle(widget.device, _isConnected()),
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
              ),
            );
          }
        },
      ),
    );
  }
}
