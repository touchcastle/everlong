import 'package:flutter/material.dart';
import 'package:everlong/ui/views/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

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
        isActive: _isShow,
        icon: svgIcon(
          name: kSettingIcon,
          width: kIconWidth,
          color: buttonLabelColor(isActive: _isShow),
        ),
        onPressed: () async {
          setState(() => _isShow = true);
          await showDialog(
            context: context,
            builder: (BuildContext context) => dialogBox(
              context: context,
              content: settingDialog(context),
            ),
          );
          setState(() => _isShow = false);
        });
  }
}
