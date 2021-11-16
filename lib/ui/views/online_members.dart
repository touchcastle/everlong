import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/models/session_participants.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/ui/views/piano/virtual_piano.dart';
import 'package:everlong/ui/widgets/online/connecting_text.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';

class OnlineMemberList extends StatefulWidget {
  @override
  _OnlineMemberListState createState() => new _OnlineMemberListState();
}

class _OnlineMemberListState extends State<OnlineMemberList> {
  final double _hostIconAreaWidth = 25.0;
  final double _pianoHeight = 40;
  final double _nameHeight = 25;

  bool _isLost(int lastSeen) =>
      (DateTime.now().millisecondsSinceEpoch - lastSeen) >
          kClockInCheckPeriod ||
      context.watch<Online>().lostConnection;

  ///Whole box for member's detail.(Non-listenable virtual piano)
  Widget _memberInfo(SessionMember _member, BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: _pianoHeight + _nameHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          _memberName(_member, context),
          _memberState(_member),
        ],
      ),
    );
  }

  ///First line of member's detail.(status icon & member's name)
  Widget _memberName(SessionMember _member, BuildContext context,
      {TextStyle style = kMemberName}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
              width: _hostIconAreaWidth,
              child: _memberStatusIcon(_member.lastSeen)),
          SizedBox(width: 3),
          Text(_member.name, style: style),
          context.read<Online>().user!.user!.uid == _member.id
              ? Text('($kMe)', style: style)
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  ///Second line of member's detail.(status text & host)
  Widget _memberState(SessionMember _member) {
    return Row(
      children: [
        SizedBox(
          width: _hostIconAreaWidth,
          child: _member.isHost
              ? SizedBox(
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: SvgPicture.asset(kHostIcon, color: kMemberDetail),
                  ),
                )
              : SizedBox.shrink(),
        ),
        SizedBox(width: 3),
        _memberStatusText(_member.lastSeen),
        // _member.isHost && _memberState(_member.lastSeen)
        _member.isHost && !_isLost(_member.lastSeen)
            ? Text(', $kHost', style: kMemberInfo)
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _memberStatusIcon(int lastSeen) {
    String _icon() => _isLost(lastSeen) ? kAmberLightIcon : kGreenLightIcon;
    return SvgPicture.asset(_icon());
  }

  Widget _memberStatusText(int lastSeen) {
    if (_isLost(lastSeen)) {
      return ConnectingAnimatedText();
    } else {
      return Text(kMemberConnected, style: kMemberInfo);
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
                      EdgeInsets.only(top: 2, bottom: 5, left: 5, right: 5),
                  child: context.watch<Online>().isRoomHost
                      ? GestureDetector(
                          onTap: () async {
                            await context.read<Online>().toggleMemberListenable(
                                memberId: _member.id,
                                listenable: !_member.listenable);
                          },
                          child: _member.listenable
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        height: _nameHeight,
                                        child: _memberName(_member, context,
                                            style: kMemberNameSmall)),
                                    VirtualPiano(
                                      _member.piano,
                                      height: _pianoHeight,
                                    ),
                                  ],
                                )
                              : _memberInfo(_member, context),
                        )
                      : _memberInfo(_member, context),
                ),
              ),
            );
          }),
    );
  }
}
