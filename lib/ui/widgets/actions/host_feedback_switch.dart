import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/texts.dart';

// class HostFeedbackSelect extends StatelessWidget {
class HostFeedbackSelect extends StatefulWidget {
  // final Type type;
  // RecorderMenu({required this.type});
  @override
  _HostFeedbackSelectState createState() => _HostFeedbackSelectState();
}

class _HostFeedbackSelectState extends State<HostFeedbackSelect> {
  bool _isOnlineHost() =>
      Setting.isOnline() && context.watch<Online>().isRoomHost;

  @override
  Widget build(BuildContext context) {
    return _isOnlineHost()
        ? Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Session\'s Notation',
                  style: TextStyle(
                    fontSize: kInfoBarTextSize,
                    color:
                        Setting.hostOnlineFeedback ? kGreen2 : Colors.black45,
                  ),
                ),
                SizedBox(width: 5),
                FlutterSwitch(
                  value: Setting.hostOnlineFeedback,
                  width: 28,
                  height: 14,
                  toggleSize: 10,
                  valueFontSize: 15,
                  activeColor: kGreen5,
                  onToggle: (value) {
                    setState(() {
                      context.read<Online>().toggleHostFeedback();
                      print(Setting.hostOnlineFeedback);
                    });
                  },
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }
}
