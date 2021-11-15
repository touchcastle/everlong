import 'package:flutter/widgets.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';

Widget localInfoBar(String masterDevice) {
  bool _noMaster() => masterDevice == kNoMaster;

  return Padding(
    padding: EdgeInsets.only(left: 10, right: 15, top: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(kMasterDevice,
            style:
                TextStyle(fontSize: kInfoBarTextSize, color: kTextColorWhite)),
        Text(_noMaster() ? kInfoNoMaster : masterDevice,
            style: TextStyle(
                fontSize: kInfoBarTextSize,
                color: _noMaster() ? kLocalAccentColor : kTextColorDark)),
      ],
    ),
  );
}
