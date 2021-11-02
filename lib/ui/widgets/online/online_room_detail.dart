import 'package:flutter/widgets.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/actions/session_link.dart';
import 'package:everlong/ui/widgets/actions/copy.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/colors.dart';

Widget roomDetail(
    {required String name, required String id, required bool isHost}) {
  TextStyle _style(Color color) =>
      TextStyle(fontSize: kInfoBarTextSize, color: color);

  return Row(
    children: [
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('User: ', style: _style(kOnlineRoomSubject)),
              Text('Session ID: ', style: _style(kOnlineRoomSubject)),
            ],
          ),
          Container(
            constraints: BoxConstraints(maxWidth: Setting.deviceWidth * 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(name, style: _style(kOnlineRoomDetail)),
                      isHost
                          ? Row(
                              children: [
                                Text(
                                  ' (Host) ',
                                  style: _style(kOnlineRoomDetail),
                                ),
                                svgIcon(
                                  name: kOnlineIcon,
                                  width: kInfoBarTextSize,
                                  color: kOnlineRoomDetail,
                                )
                              ],
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                Text(id, style: _style(kTextColorWhite)),
              ],
            ),
          ),
        ],
      ),
      SizedBox(width: 10),
      isHost ? Copy() : SizedBox.shrink(),
      isHost ? SessionLink() : SizedBox.shrink()
    ],
  );
}
