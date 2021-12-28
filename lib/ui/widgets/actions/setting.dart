import 'package:flutter/material.dart';
import 'package:everlong/ui/views/setting/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';

/// Setting button
class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isShow = false;
  @override
  Widget build(BuildContext context) {
    return Button(
        // isActive: _isShow,
        isActive: context.watch<Classroom>().showingSetting,
        icon: svgIcon(
          name: kSettingIcon,
          width: kIconWidth,
          color: buttonLabelColor(
              isActive: context.watch<Classroom>().showingSetting),
        ),
        onPressed: () async {
          // setState(() => _isShow = true);
          context.read<Classroom>().toggleShowingSetting(true);
          await showDialog(
            context: context,
            builder: (BuildContext context) => dialogBox(
              context: context,
              content: settingDialog(context),
            ),
          );
          context.read<Classroom>().toggleShowingSetting(false);
          // setState(() => _isShow = false);
        });
  }
}
