import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/views/device/device_label.dart';
import 'package:everlong/ui/widgets/actions/connection.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';

class DeviceTitle extends StatelessWidget {
  ///Bluetooth device
  final BLEDevice device;

  ///Device connection status
  final bool isConnected;

  ///Constructor
  DeviceTitle(this.device, this.isConnected);

  /// Decoration for device's box.
  /// Difference between device's connection state will appear by [color].
  BoxDecoration _deviceBoxDecor(bool isConnected) {
    Color _color() => isConnected
        ? device.isExpanding
            ? kExpandingBoxColor
            : kConnectedBoxColor
        : kDisconnectedBoxColor;
    return BoxDecoration(
      color: _color(),
      borderRadius: kAllBorderRadius,
    );
  }

  double _boxPadding() => Setting.isOnline() ? 0 : 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: device.isExpanding ? kTextColorDark : kTextColorDark,
        borderRadius: BorderRadius.all(kBorderRadius),
      ),
      padding: EdgeInsets.only(bottom: _boxPadding()),
      child: Container(
        decoration: _deviceBoxDecor(isConnected),
        child: Padding(
          padding: EdgeInsets.only(left: 5, right: 10, top: 10, bottom: 12),
          child: Row(
            children: [
              Expanded(child: DeviceLabel(device, isConnected)),
              Connection(device, isConnected),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
