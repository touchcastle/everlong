import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/recorder.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/save.dart';
import 'package:everlong/ui/widgets/dialog_header_bar.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/texts.dart';

class RecordRenameDialog extends StatefulWidget {
  final FileType fileType;
  final RecFile file;

  RecordRenameDialog({required this.fileType, required this.file});

  @override
  _RecordRenameDialogState createState() => new _RecordRenameDialogState();
}

class _RecordRenameDialogState extends State<RecordRenameDialog> {
  String? _newName;

  ///Inner horizontal padding
  EdgeInsetsGeometry _innerPad =
      EdgeInsets.symmetric(horizontal: Setting.deviceWidth * 0.08);

  ///Text field to change record name
  Padding _recordTextField(BuildContext context) {
    return Padding(
      padding: _innerPad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kRecRenameBoxLabel, style: textFieldLabel(color: kTextColorRed)),
          Theme(
            data: Theme.of(context).copyWith(
                textSelectionTheme:
                    TextSelectionThemeData(selectionColor: Colors.green)),
            child: TextFormField(
              initialValue: widget.file.name,
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

  // ///Device's metadata
  // Padding _deviceMetadata() => Padding(
  //       padding: _innerPad,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           //Device's factory name
  //           Text(
  //             ('${widget.device.device.name}  '),
  //             style: textFieldSubLabel(color: kTextColorDark),
  //           ),
  //           SizedBox(width: Setting.deviceWidth * 0.01),
  //           //Device UUID
  //           Flexible(
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: Text(
  //                 widget.device.id(),
  //                 textAlign: TextAlign.right,
  //                 style: textFieldSubLabel(color: kTextColorDark),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );

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
              title: kRecRenameHeader,
            ),
            _verticalSpace(0.03),
            _recordTextField(context),
            // _verticalSpace(0.005),
            // _deviceMetadata(),
            _verticalSpace(0.02),
            Save(
              onPressed: () async {
                try {
                  context
                      .read<Recorder>()
                      .renameRecord(widget.file, _newName!, widget.fileType);
                  Navigator.pop(context);
                } catch (e) {
                  Snackbar.show(
                    context,
                    text: e.toString(),
                    icon: kErrorIcon,
                    dialogWidth: true,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
