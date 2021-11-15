import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:everlong/ui/widgets/online/clock.dart';
import 'package:everlong/ui/widgets/online/online_member_counter.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/texts.dart';

Widget onlineInfoBar() {
  final TextStyle _style = TextStyle(
      color: kTextColorLight,
      fontSize: kInfoBarTextSize,
      fontWeight: FontWeight.w500);

  return Container(
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.only(left: 10, right: 15, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(kParticipant, style: _style),
              OnlineMemberCounter(),
            ],
          ),
          Row(
            children: [
              Text(kTime, style: _style),
              Clock(),
            ],
          ),
        ],
      ),
    ),
  );
}
