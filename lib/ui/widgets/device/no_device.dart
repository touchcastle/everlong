import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/styles.dart';

class NoDeviceDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                kNoDeviceText,
                style: noDeviceTextStyle(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
