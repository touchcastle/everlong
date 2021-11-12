import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/styles.dart';

Widget dialogBox({
  required BuildContext context,
  required Widget content,
  smallerDialog = false,
}) {
  double _dialogRatio() => Setting.isTablet()
      ? smallerDialog
          ? 0.5
          : 0.6
      : smallerDialog
          ? 0.7
          : 0.8;

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
