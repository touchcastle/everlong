import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/bluetooth.dart';
import 'package:everlong/ui/widgets/progress_indicator.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/styles.dart';

/// Generate scan button
class Scan extends StatelessWidget {
  final bool isExpanded;
  final bool isVertical;
  final bool isDialogButton;
  final double paddingVertical;
  final BorderRadiusGeometry? borderRadius;
  final Function()? onScanPressed;
  Scan({
    this.borderRadius,
    this.isExpanded = false,
    this.paddingVertical = 0,
    this.isDialogButton = false,
    required this.isVertical,
    this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.watch<BluetoothControl>().flutterBlue.isScanning,
      initialData: false,
      builder: (c, scanSnapshot) {
        bool _isScanning = scanSnapshot.data!;
        return Button(
          borderRadius: this.borderRadius ?? null,
          isActive: _isScanning,
          isExpanded: this.isExpanded,
          isVertical: this.isVertical,
          paddingVertical: this.paddingVertical,
          icon: progressIndicator(animate: _isScanning),
          text: Text(
            kScan,
            style: buttonTextStyle(
              isActive: _isScanning,
              isVertical: this.isVertical,
              isDialogButton: this.isDialogButton,
            ),
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            onScanPressed;
            context.read<BluetoothControl>().doScan(timeout: kReScanDuration);
          },
        );
      },
    );
  }
}
