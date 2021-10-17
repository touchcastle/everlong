import 'package:flutter/widgets.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/constants.dart';

Widget localInfoBar(String masterDevice) {
  return Padding(
    padding: EdgeInsets.only(left: 10, right: 15, top: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(kMasterDevice,
            style:
                TextStyle(fontSize: kInfoBarTextSize, color: kTextColorWhite)),
        Text(masterDevice == kNoMaster ? kInfoNoMaster : masterDevice,
            style:
                TextStyle(fontSize: kInfoBarTextSize, color: kTextColorDark)),
      ],
    ),
  );
}
