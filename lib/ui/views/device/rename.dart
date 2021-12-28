import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/bluetooth.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/save.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/texts.dart';

class RenameDialog extends StatefulWidget {
  final BLEDevice device;
  RenameDialog(this.device);

  @override
  _RenameDialogState createState() => new _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  String? _newName;

  ///Inner horizontal padding
  EdgeInsetsGeometry _innerPad =
      EdgeInsets.symmetric(horizontal: Setting.deviceWidth * 0.08);

  ///Text field to change device name
  Padding _deviceTextField(BuildContext context) {
    return Padding(
      padding: _innerPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kRenameBoxLabel, style: textFieldLabel(color: kTextColorRed)),
          Theme(
            data: Theme.of(context).copyWith(
                textSelectionTheme:
                    TextSelectionThemeData(selectionColor: Colors.green)),
            child: TextFormField(
              initialValue: widget.device.displayName,
              style: kTextFieldStyle,
              cursorColor: Colors.black,
              autofocus: true,
              enabled: true,
              decoration: kRenameTextDecor(kRenameBoxLabel),
              onChanged: (newText) => _newName = newText,
            ),
          ),
        ],
      ),
    );
  }

  ///Device's metadata
  Padding _deviceMetadata() => Padding(
        padding: _innerPad,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Device's factory name
            Text(
              ('${widget.device.device.name}  '),
              style: textFieldSubLabel(color: kTextColorDark),
            ),
            SizedBox(width: Setting.deviceWidth * 0.01),
            //Device UUID
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
      );

  SizedBox _verticalSpace(double multiplier) =>
      SizedBox(height: Setting.deviceHeight * multiplier);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: kAllBorderRadius,
        gradient: kBGGradient(kLocalBG),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            dialogHeaderBar(
              barColor: kLocalAccentColor,
              exitIconAreaColor: kYellowMain,
              exitIconColor: kTextColorRed,
              titleIconName: kRenameIcon,
              title: kRenameHeader,
            ),
            _verticalSpace(0.03),
            _deviceTextField(context),
            _verticalSpace(0.005),
            _deviceMetadata(),
            _verticalSpace(0.02),
            Save(
              onPressed: () async {
                await context.read<Classroom>().updateDeviceDisplayName(
                    id: widget.device.id(), name: _newName!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
