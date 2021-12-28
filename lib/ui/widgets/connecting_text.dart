import 'dart:async';
import 'package:flutter/material.dart';
import 'package:everlong/utils/styles.dart';

class ConnectingAnimatedText extends StatefulWidget {
  @override
  _ConnectingAnimatedTextState createState() =>
      new _ConnectingAnimatedTextState();
}

class _ConnectingAnimatedTextState extends State<ConnectingAnimatedText> {
  String _output = 'Connecting';
  int _index = 0;
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _clockText());
    super.initState();
  }

  void _clockText() {
    setState(() => _output = _printDuration());
  }

  String _printDuration() {
    String _out = '';
    switch (_index) {
      case 0:
        _out = 'Connecting.  ';
        _index++;
        break;
      case 1:
        _out = 'Connecting.. ';
        _index++;
        break;
      case 2:
        _out = 'Connecting...';
        _index = 0;
        break;
    }
    return _out;
  }

  //
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(_output, style: kMemberInfo);
}
