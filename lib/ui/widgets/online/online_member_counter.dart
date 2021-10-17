import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/constants.dart';

class OnlineMemberCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
        '${context.watch<Online>().membersList.length}/${kMaxMember.toString()}',
        style: TextStyle(
          color: kOnlineRoomDetail,
          fontSize: kInfoBarTextSize,
        ));
  }
}
