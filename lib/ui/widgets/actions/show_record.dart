import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/widgets/button.dart';
import 'package:everlong/ui/widgets/svg.dart';
import 'package:everlong/utils/styles.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/colors.dart';

class ShowRecord extends StatefulWidget {
  @override
  _ShowRecordState createState() => _ShowRecordState();
}

class _ShowRecordState extends State<ShowRecord> {
  @override
  Widget build(BuildContext context) {
    bool _isShow = context.watch<Classroom>().showRecorder;
    return Button(
      isActive: _isShow,
      icon: svgIcon(

          ///TODO: unusable icon
          // name: kRecordIcon,
          // name: widget.type == Type.Local ? kRecStartIcon : kShareIcon,
          name: Setting.isOffline() ? kRecStartIcon : kShareIcon,
          color: _isShow
              ? Colors.white
              : Setting.isOnline()
                  ? kOnlineInactiveLabel
                  : kLocalInactiveLabel,
          width: Setting.isOffline() ? kIconWidth : kIconWidth + 10),
      text: Text(Setting.isOffline() ? 'Record' : 'Share',
          style: buttonTextStyle(isActive: _isShow, isVertical: true),
          textAlign: TextAlign.center),
      onPressed: () => context.read<Classroom>().toggleRecordManagerDisplay(),
    );
  }
}
