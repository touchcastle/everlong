import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/constants.dart';

Widget dialogBox({
  required BuildContext context,
  required Widget content,
  smallerDialog = false,
}) {
  double _dialogRatio() => Setting.isTablet()
      ? smallerDialog
          ? 0.55
          : kTabletDialogRatio
      : smallerDialog
          ? 0.7
          : kMobileDialogRatio;

  final BoxConstraints _constraints = BoxConstraints(
    maxWidth: Setting.deviceWidth * _dialogRatio(),
    maxHeight: Setting.deviceHeight * _dialogRatio(),
    minWidth: 200,
    // minHeight: 250,
  );

  return Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: _constraints,
      decoration: kDialogDecor,
      child: content,
      // child: Text('test'),
    ),
  );
}
