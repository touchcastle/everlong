import 'package:flutter/material.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/ui/views/rename.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

///Generate device's rename button.
class Rename extends StatefulWidget {
  Rename({required this.device});
  final BLEDevice device;

  @override
  State<Rename> createState() => _RenameState();
}

class _RenameState extends State<Rename> {
  bool _isShow = false;
  @override
  Widget build(BuildContext context) {
    return Button(
        isActive: _isShow,
        icon: svgIcon(
          name: kRenameIcon,
          color: _isShow ? Colors.white : kTextColorDark,
        ),
        onPressed: () async {
          setState(() => _isShow = true);
          await showDialog(
            context: context,
            builder: (BuildContext context) => dialogBox(
              context: context,
              content: RenameDialog(widget.device),
            ),
          );
          setState(() => _isShow = false);
        });
  }
}
