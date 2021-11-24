import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/utils/midi.dart';

class Recorder extends ChangeNotifier {
  Classroom classroom;
  List<RecEvent> events = [];
  late RecFile file;
  late int startTime;
  late int totalTime;
  final int milliSecDivide = 10;

  Recorder(this.classroom);

  void start() {
    if (events.isEmpty) {
      // New record
      _clearParams();
      startTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      // Overwrite?

      // If OK
      _clearParams();
      startTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void _clearParams() {
    events.clear();
    file.clear();
    startTime = 0;
    totalTime = 0;
  }

  void record({required Uint8List data}) {
    int _now = DateTime.now().millisecondsSinceEpoch;
    int _deltaTime = (_now - startTime) ~/ milliSecDivide;
    events.add(RecEvent(time: _deltaTime, data: data));
  }

  void stop() {
    totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
    file = RecFile(totalTime: totalTime, events: events);
  }

  Future play() async {
    List<RecEvent> _toPlay = [];
    _toPlay.add(RecEvent(time: 0, data: kMidCSound));
    _toPlay.add(RecEvent(time: 10, data: kMidCSound));
    _toPlay.add(RecEvent(time: 20, data: kMidCSound));
    _toPlay.add(RecEvent(time: 1000, data: kMidCSound));
    _toPlay.add(RecEvent(time: 2000, data: kMidCSound));
    RecFile _play = RecFile(totalTime: 400, events: _toPlay);
    print('play');
    int i = 0;
    Timer.periodic(Duration(milliseconds: 10), (Timer t) async {
      if (_play.events.isNotEmpty) {
        if (_play.events[0].time <= i) {
          print(i);
          // classroom.sendLocal(_play.events[0].data,
          //     withSound: true, withLight: true);
          _play.events.removeAt(0);
        }
      }
      if (i >= 3000){
        t.cancel();
      }
      i = i + 10;
    });
  }

}
