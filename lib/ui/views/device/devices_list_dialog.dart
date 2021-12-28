import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/services/animation.dart';
import 'package:everlong/ui/views/device/device_box.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:everlong/ui/views/device/no_device.dart';
import 'package:everlong/ui/widgets/actions/scan.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

class DeviceAnimatedListDialog extends StatefulWidget {
  @override
  _DeviceAnimatedListDialogState createState() =>
      new _DeviceAnimatedListDialogState();
}

class _DeviceAnimatedListDialogState extends State<DeviceAnimatedListDialog> {
  dynamic _scanSub;

  @override
  void initState() {
    super.initState();
    context.read<BluetoothControl>().doScan();
    _scanSub = context
        .read<BluetoothControl>()
        .collectScanResult()
        .listen((result) => result ? setState(() {}) : setState(() {}));
    // .listen((result) => result ? setState(() {}) : null);
  }

  @override
  void dispose() {
    super.dispose();
    _scanSub?.cancel();
  }

  ListView _devicesList(BuildContext context) {
    return ListView.builder(
      key: context.watch<ListAnimation>().animateListKey,
      itemCount: context.watch<Classroom>().bluetoothDevices.length,
      itemBuilder: (context, index) {
        BLEDevice device = context.watch<Classroom>().bluetoothDevices[index];
        return DeviceBox(device, enableFunction: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isNotEmpty = context.watch<Classroom>().bluetoothDevices.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(kBorderRadius),
        gradient: kBGGradient(kOnlineBG),
      ),
      child: Column(
        children: [
          dialogHeaderBar(
            barColor: kOnlineAccentColor,
            exitIconAreaColor: kDarkOnlineBG,
            titleIconName: kDeviceManageIcon,
            title: kDevicesMng,
          ),
          Expanded(
            child: _isNotEmpty
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: _devicesList(context),
                  )
                : NoDeviceDisplay(),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: kBottom,
              color: kOnlineAccentColor,
            ),
            child: Row(
              children: [
                Scan(
                    borderRadius: kBottom,
                    isVertical: false,
                    isExpanded: true,
                    isDialogButton: true,
                    paddingVertical: 5,
                    onScanPressed: () => setState(() {})),
              ],
            ),
          )
        ],
      ),
    );
  }
}
