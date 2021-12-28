import 'package:flutter/widgets.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/session_link.dart';
import 'package:everlong/ui/widgets/actions/copy.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/texts.dart';

class RoomInfoAndShare extends StatelessWidget {
  ///Username
  final String name;

  ///Session ID
  final String id;

  ///Flag true if user is session host
  final bool isHost;

  RoomInfoAndShare(
      {required this.name, required this.id, required this.isHost});

  TextStyle _style(Color color) =>
      TextStyle(fontSize: kInfoBarTextSize, color: color);

  ///Room information label
  Column _roomInfoLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$kUsername: ', style: _style(kOnlineRoomSubject)),
        Text('$kSessionId: ', style: _style(kOnlineRoomSubject)),
      ],
    );
  }

  ///Show text and icon for host.
  Widget _host() => isHost
      ? Row(
          children: [
            Text(' ($kHost) ', style: _style(kOnlineRoomDetail)),
            svgIcon(
              name: kOnlineIcon,
              width: kInfoBarTextSize,
              color: kOnlineRoomDetail,
            )
          ],
        )
      : SizedBox.shrink();

  ///Room information detail
  Container _roomInfoDetail() {
    return Container(
      constraints: BoxConstraints(maxWidth: Setting.deviceWidth * 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(name, style: _style(kOnlineRoomDetail)),
                _host(),
              ],
            ),
          ),
          Text(id, style: _style(kTextColorWhite)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            _roomInfoLabel(),
            _roomInfoDetail(),
          ],
        ),
        SizedBox(width: 10),
        isHost ? Copy() : SizedBox.shrink(),
        isHost ? SessionLink() : SizedBox.shrink()
      ],
    );
  }
}
