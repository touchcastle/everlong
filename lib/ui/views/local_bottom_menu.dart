import 'package:flutter/material.dart';
import 'package:everlong/ui/widgets/actions/hold.dart';
import 'package:everlong/ui/widgets/actions/reset.dart';
import 'package:everlong/ui/widgets/actions/scan.dart';
import 'package:everlong/ui/widgets/actions/ping_all.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';

class LocalBottomMenu extends StatelessWidget {
  final Function()? onScanPressed;
  LocalBottomMenu({this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kLocalAccentColor,
      padding: kBottomPanePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Hold(),
          Reset(),
          Scan(isVertical: true, onScanPressed: onScanPressed),
          PingAll(),
        ],
      ),
    );
  }
}
