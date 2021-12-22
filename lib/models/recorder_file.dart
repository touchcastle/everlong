import 'package:flutter/foundation.dart';

class RecEvent {
  final int time;
  final List<int> data;

  RecEvent({
    required this.time,
    required this.data,
  });
}

class RecFile extends ChangeNotifier {
  String name;
  int totalTimeMilliSec;
  int totalTimeSec;
  String totalTimeSecText;
  bool isPlaying;
  bool isEditingName;
  List<RecEvent> events;

  RecFile({
    required this.totalTimeMilliSec,
    required this.totalTimeSec,
    required this.totalTimeSecText,
    required this.events,
    this.isPlaying = false,
    this.isEditingName = true,
    this.name = 'New Record',
  });

  void clear() {
    totalTimeMilliSec = 0;
    events.clear();
  }
}
