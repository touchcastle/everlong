import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/midi.dart';

class Recorder extends ChangeNotifier {
  Classroom classroom;
  List<RecEvent> events = [];
  RecFile? file;
  int startTime = 0;
  int totalTime = 0;
  final int milliSecDivide = 10;

  Recorder(this.classroom);

  void start() {
    print('START');
    if (events.isEmpty) {
      // New record
      _clearParams();
      startTime = DateTime.now().millisecondsSinceEpoch;
      Setting.isRecording = true;
    } else {
      // Overwrite?

      // If OK
      _clearParams();
      startTime = DateTime.now().millisecondsSinceEpoch;
      Setting.isRecording = true;
    }
  }

  void _clearParams() {
    events.clear();
    file?.clear();
    startTime = 0;
    totalTime = 0;
  }

  void record({required List<int> raw}) {
    int _now = DateTime.now().millisecondsSinceEpoch;
    // int _deltaTime = (_now - startTime) ~/ milliSecDivide;
    int _deltaTime = (_now - startTime);
    events.add(RecEvent(time: _deltaTime, data: raw));
    print(events.length);
  }

  void stop() {
    totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
    file = RecFile(totalTime: totalTime, events: events);
    Setting.isRecording = false;
    print('TOTAL: ${file!.totalTime} / ${file!.events.length}');
  }

  Future play() async {
    List<RecEvent> _play = List.from(file!.events);

    int i = 0;
    Timer.periodic(Duration(milliseconds: milliSecDivide), (Timer t) async {
      if (_play.isNotEmpty) {
        if (_play[0].time <= i) {
          final Uint8List _uintData = Uint8List.fromList(_play[0].data);
          classroom.sendLocal(_uintData,
              withSound: true, withLight: true, withMaster: true);
          _play.removeAt(0);
        }
      }
      if (i >= file!.totalTime) {
        t.cancel();
        print('FINISHED');
      }
      i = i + milliSecDivide;
    });
  }
}
