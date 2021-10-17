import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/ui/widgets/device/device_name.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/sizes.dart';

class DeviceLabel extends StatelessWidget {
  final BLEDevice device;
  final bool isConnected;
  final double _hostIconHeight = 20.0;
  final double _hostIconAreaWidth = 25.0;
  final double _hostIconAreaHeight = 25.0;
  DeviceLabel(this.device, this.isConnected);

  Widget _showHostIcon() => SizedBox(
        height: _hostIconHeight,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: SvgPicture.asset(kHostIcon,
              width: 12,
              color: this.device.isExpanding
                  ? kConnectedBoxColor
                  : kConnectedTextColor),
        ),
      );

  Widget _showConnectStatus() {
    if (!this.device.isConnecting) {
      if (this.isConnected) {
        return Text(
          kConnectedText,
          style: TextStyle(
              color:
                  device.isExpanding ? kConnectedBoxColor : kConnectedTextColor,
              fontSize: kDeviceStatus),
        );
      } else {
        return Text(kDisconnectedText,
            style: TextStyle(
                color: kDisconnectedTextColor, fontSize: kDeviceStatus));
      }
    } else {
      return Text(kConnectingText,
          style: TextStyle(
              color: kDisconnectedTextColor, fontSize: kDeviceStatus));
    }
  }

  Widget _showMasterText() => Text(
        kHost,
        style: TextStyle(
            color: this.isConnected
                ? device.isExpanding
                    ? kConnectedBoxColor
                    : kTextColorDark
                : kOrange5,
            fontSize: kDeviceStatus),
      );

  @override
  Widget build(BuildContext context) {
    bool _showAsMaster() =>
        this.device.isMaster ||
        (Setting.sessionMode == SessionMode.online &&
            context.read<Online>().isRoomHost);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: _hostIconAreaWidth),
            SizedBox(width: 3),
            DeviceName(device: device, isConnected: this.isConnected),
          ],
        ),
        // SizedBox(height: 5.0),
        SizedBox(
          height: _hostIconAreaHeight,
          child: Row(children: [
            SizedBox(
                width: _hostIconAreaWidth,
                child: _showAsMaster() ? _showHostIcon() : SizedBox.shrink()),
            SizedBox(width: 3),
            _showConnectStatus(),
            _showAsMaster() ? _showMasterText() : SizedBox.shrink(),
          ]),
        ),
      ],
    );
  }
}
