import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/session_participants.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/widgets/online/connecting_text.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';

class OnlineMemberList extends StatefulWidget {
  @override
  _OnlineMemberListState createState() => new _OnlineMemberListState();
}

class _OnlineMemberListState extends State<OnlineMemberList> {
  final double _hostIconAreaWidth = 25.0;

  @override
  void initState() {
    super.initState();
  }

  bool _isLost(int lastSeen) =>
      (DateTime.now().millisecondsSinceEpoch - lastSeen) >
          kClockInCheckPeriod ||
      context.watch<Online>().lostConnection;

  Widget _memberStateIcon(int lastSeen) {
    String _icon() => _isLost(lastSeen) ? kAmberLightIcon : kGreenLightIcon;
    return SvgPicture.asset(_icon());
  }

  Widget _memberStateText(int lastSeen) {
    if (_isLost(lastSeen)) {
      return ConnectingAnimatedText();
    } else {
      return Text('Connected', style: kMemberInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
          itemCount: context.watch<Online>().membersList.length,
          itemBuilder: (BuildContext context, int _index) {
            SessionMember _member = context.watch<Online>().membersList[_index];
            return Padding(
              padding: kDeviceBoxOuterPadding,
              child: Container(
                decoration: BoxDecoration(
                    color: kMemberBox, borderRadius: kAllBorderRadius),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                                width: _hostIconAreaWidth,
                                child: _memberStateIcon(_member.lastSeen)),
                            SizedBox(width: 3),
                            Text(_member.name, style: kMemberName),
                            context.read<Online>().user!.user!.uid == _member.id
                                ? Text('(me)', style: kMemberName)
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: _hostIconAreaWidth,
                            child: _member.isHost
                                ? SizedBox(
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(2),
                                      child: SvgPicture.asset(
                                        kHostIcon,
                                        color: kMemberDetail,
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ),
                          SizedBox(width: 3),
                          _memberStateText(_member.lastSeen),
                          // _member.isHost && _memberState(_member.lastSeen)
                          _member.isHost && !_isLost(_member.lastSeen)
                              ? Text(', Host', style: kMemberInfo)
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
