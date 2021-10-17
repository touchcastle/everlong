import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/progress_indicator.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

class Connection extends StatefulWidget {
  final BLEDevice device;
  final bool isConnected;
  Connection(this.device, this.isConnected);

  @override
  _ConnectionState createState() => new _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  Future _connection() async {
    setState(() => widget.device.isConnecting = true);
    widget.isConnected && widget.device.isConnected()
        ? await widget.device.disconnect()
        : await context.read<BluetoothControl>().connectTo(widget.device);
    setState(() => widget.device.isConnecting = false);
  }

  String _icon() => widget.isConnected && widget.device.isConnected()
      ? kBluetoothIconConnected
      : kBluetoothIconDisconnected;

  Color _color() => widget.device.isExpanding
      ? kConnectedBoxColor
      : widget.isConnected && widget.device.isConnected()
          ? kConnectedTextColor
          : kDisconnectedTextColor;

  @override
  Widget build(BuildContext context) {
    if (!widget.device.isConnecting) {
      return GestureDetector(
        onTap: () async => await _connection(),
        child: svgIcon(
          name: _icon(),
          width: 32,
          color: _color(),
        ),
      );
    } else {
      return progressIndicator(onTap: () async {
        await widget.device.disconnect();
        setState(() => widget.device.isConnecting = false);
      });
    }
  }
}
