import 'package:flutter/material.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/styles.dart';

Widget dialogBox({required BuildContext context, required Widget content}) {
  double _dialogRatio() => Setting.isTablet() ? 0.6 : 0.8;

  final BoxConstraints _constraints = BoxConstraints(
    maxWidth: Setting.deviceWidth * _dialogRatio(),
    maxHeight: Setting.deviceHeight * _dialogRatio(),
    minWidth: 300,
    minHeight: 250,
  );

  return Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: _constraints,
      decoration: kDialogDecor,
      child: content,
    ),
  );
}
