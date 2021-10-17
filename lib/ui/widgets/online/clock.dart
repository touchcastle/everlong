import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everlong/services/online.dart';
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/sizes.dart';
import 'package:everlong/utils/styles.dart';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => new _ClockState();
}

class _ClockState extends State<Clock> {
  String _clockString = '00:00:00';
  late Timer _timer;
  late int _elapsed;

  @override
  void initState() {
    _getElapsed();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _clockText());
    super.initState();
  }

  //
  void _getElapsed() {
    DateTime _createTime = DateTime.fromMicrosecondsSinceEpoch(
        context.read<Online>().roomCreateTime * 1000);
    _elapsed = DateTime.now().difference(_createTime).inSeconds;
  }

  void _clockText() {
    _elapsed++;
    final _clock = Duration(seconds: _elapsed);
    setState(() => _clockString = _printDuration(_clock));
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  //
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(_clockString,
      style: TextStyle(
        color: kOnlineRoomDetail,
        fontFamily: kSecondaryFontFamily,
        fontSize: kInfoBarTextSize,
      ));
}
