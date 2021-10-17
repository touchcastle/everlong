import 'package:flutter/material.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

class DeviceName extends StatelessWidget {
  final BLEDevice device;
  final bool isConnected;
  final double width = 150;
  DeviceName({required this.device, required this.isConnected});

  TextStyle _textStyle() {
    return TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 22,
        color: isConnected && device.isConnected()
            ? device.isExpanding
                ? kConnectedBoxColor
                : kConnectedTextColor
            : kDisconnectedTextColor);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(device.displayName, style: _textStyle()),
      ),
    );
  }
}
