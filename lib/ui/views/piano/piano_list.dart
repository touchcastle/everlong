import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/session_participants.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/piano.dart';
import 'package:everlong/ui/widgets/actions/listen.dart';
import 'package:everlong/ui/views/piano/virtual_piano.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';

class PianoList extends StatefulWidget {
  List<dynamic> lists = [];
  PianoList({required this.lists});
  @override
  _PianoListState createState() => new _PianoListState();
}

class _PianoListState extends State<PianoList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
          itemCount: context.watch<Online>().membersList.length,
          // itemCount: widget.lists.length,
          itemBuilder: (BuildContext context, int _index) {
            Piano _piano = context.watch<Online>().membersList[_index].piano;
            // Piano _piano = widget.lists[_index].piano;
            return Padding(
              padding: kDeviceBoxOuterPadding,
              child: Container(
                decoration: BoxDecoration(
                    color: kMemberBox, borderRadius: kAllBorderRadius),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 10),
                  child: VirtualPiano(_piano),
                ),
              ),
            );
          }),
    );
  }
}
