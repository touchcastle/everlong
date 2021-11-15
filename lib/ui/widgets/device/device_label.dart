import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/utils/texts.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/styles.dart';

class DeviceLabel extends StatelessWidget {
  final BLEDevice device;
  final bool isConnected;
  final double _hostIconHeight = 20.0;
  final double _hostIconAreaWidth = 25.0;
  final double _hostIconAreaHeight = 25.0;
  DeviceLabel(this.device, this.isConnected);

  ///Display master device icon
  SizedBox _masterIcon(bool isMaster) => SizedBox(
      width: _hostIconAreaWidth,
      child: isMaster
          ? SizedBox(
              height: _hostIconHeight,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: SvgPicture.asset(kHostIcon,
                    width: 12, color: _expandColor()),
              ),
            )
          : _empty);

  ///Display master device status
  Widget _masterText(bool isMaster) => isMaster
      ? Text(
          ', $kMaster',
          style: TextStyle(
              color: this.isConnected ? _expandColor() : kOrange5,
              fontSize: kDeviceStatus),
        )
      : _empty;

  ///Label color depend on box expanding
  Color _expandColor() =>
      device.isExpanding ? kConnectedBoxColor : kTextColorDark;

  ///Display bluetooth device connection status
  Widget _Connectivity() {
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

  ///Display device name with left space [_hostIconAreaWidth]
  Row _name() => Row(
        children: [
          SizedBox(width: _hostIconAreaWidth),
          SizedBox(width: 3),
          // DeviceName(device: device, isConnected: this.isConnected),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(device.displayName, style: _nameStyle()),
            ),
          )
        ],
      );

  ///Style for device name
  TextStyle _nameStyle() => TextStyle(
      fontFamily: kPrimaryFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 22,
      color: isConnected && device.isConnected()
          ? device.isExpanding
              ? kConnectedBoxColor
              : kConnectedTextColor
          : kDisconnectedTextColor);

  final SizedBox _empty = SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    bool _isMaster() =>
        this.device.isMaster ||
        (Setting.sessionMode == SessionMode.online &&
            context.read<Online>().isRoomHost);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _name(),
        SizedBox(
          height: _hostIconAreaHeight,
          child: Row(children: [
            _masterIcon(_isMaster()),
            SizedBox(width: 3),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _Connectivity(),
                    _masterText(_isMaster()),
                    // _isMaster() ? _masterText() : _empty,
                  ],
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
