import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/device/device_label.dart';
import 'package:everlong/ui/widgets/actions/connection.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';

class DeviceTitle extends StatelessWidget {
  final BLEDevice device;
  final bool isConnected;
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
      borderRadius: BorderRadius.all(kBorderRadius),
    );
  }

  double _expandPadding() => device.isExpanding ? 3 : 0;
  double _boxPadding() => Setting.isOnline() ? 0 : 10;
  double _innerBoxBottomPadding() => Setting.isOnline() ? 15 : 10;
  double _innerBoxPadding() => device.isExpanding ? 12 : 15;
  double _innerBoxLeftPadding() => device.isExpanding ? 2 : 5;

  @override
  Widget build(BuildContext context) {
    ///Without border
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
              Expanded(child: DeviceLabel(this.device, this.isConnected)),
              Connection(device, this.isConnected),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );

    ///With border
    // return Container(
    //   decoration: BoxDecoration(
    //     color: kConnectedBoxColor,
    //     borderRadius: BorderRadius.all(kBorderRadius),
    //   ),
    //   padding: EdgeInsets.only(
    //       top: _expandPadding(),
    //       left: _expandPadding(),
    //       right: _expandPadding()),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       color: device.isExpanding ? kTextColorDark : kTextColorDark,
    //       borderRadius: BorderRadius.all(kBorderRadius),
    //     ),
    //     padding: EdgeInsets.only(bottom: _boxPadding()),
    //     child: Container(
    //       decoration: _deviceBoxDecor(isConnected),
    //       child: Padding(
    //         padding: EdgeInsets.only(
    //             left: _innerBoxLeftPadding(),
    //             right: _innerBoxPadding(),
    //             top: _innerBoxPadding(),
    //             bottom: _innerBoxBottomPadding()),
    //         child: Row(
    //           children: [
    //             Expanded(child: DeviceLabel(this.device, this.isConnected)),
    //             Connection(device, this.isConnected),
    //             SizedBox(width: 10),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
