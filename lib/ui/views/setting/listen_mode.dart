import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/ui/views/setting/mode.dart';

class ModeSelect extends StatefulWidget {
  @override
  _ModeSelectState createState() => new _ModeSelectState();
}

class _ModeSelectState extends State<ModeSelect> {
  Widget _modeList(bool _isTablet,
          {required MainAxisAlignment mainAxisAlignment,
          required List<Widget> children}) =>
      _isTablet
          ? Row(mainAxisAlignment: mainAxisAlignment, children: children)
          : Column(children: children);

  Widget _coverWith(bool _isTablet, {required Widget child}) =>
      _isTablet ? Expanded(child: child) : Container(child: child);

  @override
  Widget build(BuildContext context) {
    return _modeList(
      Setting.isTablet(),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ListenMode.values.map((ListenMode listenMode) {
        return _coverWith(
          Setting.isTablet(),
          child: Padding(
            padding: EdgeInsets.only(bottom: Setting.isTablet() ? 0 : 10),
            child: mode(
              context,
              listenMode,
              onPressed: () => setState(() {
                Setting.changeMode(listenMode);
                context.read<Classroom>().devicesIncrement();
              }),
            ),
          ),
        );
      }).toList(),
    );
  }
}
