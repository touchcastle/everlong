import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/ui/views/device/devices_list_dialog.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/constants.dart';

class DeviceManager extends StatefulWidget {
  @override
  State<DeviceManager> createState() => _DeviceManagerState();
}

class _DeviceManagerState extends State<DeviceManager> {
  bool _isShow = false;
  @override
  Widget build(BuildContext context) {
    return Button(
      isActive: _isShow,
      icon: svgIcon(
        name: kDeviceManageIcon,
        width: kIconWidth,
        color: buttonLabelColor(isActive: _isShow),
      ),
      text: Text(kDeviceManager,
          style: buttonTextStyle(isVertical: true, isActive: _isShow),
          textAlign: TextAlign.center),
      onPressed: () async {
        setState(() => _isShow = true);
        context.read<Classroom>().closeAllExpanding();
        await showDialog(
          context: context,
          builder: (BuildContext context) => dialogBox(
            context: context,
            content: DeviceAnimatedListDialog(),
          ),
        );
        setState(() => _isShow = false);
      },
    );
  }
}
