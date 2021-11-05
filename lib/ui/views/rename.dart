import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/ui/widgets/actions/save.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';

// Widget renameDialog(BuildContext context, BLEDevice device) {

class RenameDialog extends StatefulWidget {
  final BLEDevice device;
  RenameDialog(this.device);

  @override
  _RenameDialogState createState() => new _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  String? _newName;

  @override
  Widget build(BuildContext context) {
    // final double _screenWidth = MediaQuery.of(context).size.width;
    // final double _screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(kBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.2, 0.9],
          colors: kLocalBG,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dialogHeaderBar(
              barColor: kLocalAccentColor,
              exitIconAreaColor: kYellowMain,
              exitIconColor: kTextColorRed,
              titleIconName: kRenameIcon,
              title: 'Rename Midi Device',
            ),
            SizedBox(height: Setting.deviceHeight * 0.03),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Setting.deviceWidth * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device Name',
                      style: textFieldLabel(color: kTextColorRed)),
                  Theme(
                    data: Theme.of(context).copyWith(
                        textSelectionTheme: TextSelectionThemeData(
                            selectionColor: Colors.green)),
                    child: TextFormField(
                      initialValue: widget.device.displayName,
                      style: kTextFieldStyle,
                      cursorColor: Colors.black,
                      autofocus: true,
                      enabled: true,
                      decoration: kRenameTextDecor('Device name'),
                      onChanged: (newText) => _newName = newText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Setting.deviceHeight * 0.005),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Setting.deviceWidth * 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ('${widget.device.device.name}  '),
                    style: textFieldSubLabel(color: kTextColorDark),
                  ),
                  SizedBox(width: Setting.deviceWidth * 0.01),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        widget.device.id(),
                        textAlign: TextAlign.right,
                        style: textFieldSubLabel(color: kTextColorDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Setting.deviceHeight * 0.02),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(kBorderRadius),
                  color: Color(0xffF9CC58)),
              child: Save(
                onPressed: () {
                  if (_newName != null)
                    context.read<Classroom>().updateDeviceDisplayName(
                        id: widget.device.id(), name: _newName!);
                  Navigator.pop(context);
                },
              ),
            ),
            // Container(
            //     child: TextButton(
            //   child: Text('Confirm'),
            //   onPressed: () {
            //     context.read<Classroom>().updateDeviceDisplayName(
            //         id: widget.device.id(), name: _newName!);
            //     Navigator.pop(context);
            //   },
            // )),
          ],
        ),
      ),
    );
  }
}
