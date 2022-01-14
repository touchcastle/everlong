import 'package:flutter/foundation.dart';

///Which note at what time = 1 event.
///Many events to chord / music.
class RecEvent {
  final int time;
  final List<int> data;

  RecEvent({
    required this.time,
    required this.data,
  });
}

///Recorded file.
class RecFile extends ChangeNotifier {
  ///UUID for each file
  String id;

  ///Record's name
  String name;

  ///Record's duration in millisecond
  int totalTimeMilliSec;

  ///Record's duration in second
  int totalTimeSec;

  ///Record's duration in String (M:SS)
  String totalTimeSecText;

  ///Is this file currently playing
  bool isPlaying;

  ///Is active for do any action via local/online session
  bool isActive;

  ///Is playing as loop.
  bool isLoop;

  ///Events(simulate MIDI events)
  List<RecEvent> events;

  RecFile({
    required this.id,
    required this.totalTimeMilliSec,
    required this.totalTimeSec,
    required this.totalTimeSecText,
    required this.events,
    this.isPlaying = false,
    this.isActive = false,
    this.isLoop = false,
    this.name = 'New Record',
  });

  //To clone.
  RecFile copyWith({
    String? id,
    String? name,
    int? totalTimeMilliSec,
    int? totalTimeSec,
    String? totalTimeSecText,
    bool? isPlaying,
    bool? isActive,
    List<RecEvent>? events,
  }) {
    return RecFile(
      id: id ?? this.id,
      name: name ?? this.name,
      totalTimeMilliSec: totalTimeMilliSec ?? this.totalTimeMilliSec,
      totalTimeSec: totalTimeSec ?? this.totalTimeSec,
      totalTimeSecText: totalTimeSecText ?? this.totalTimeSecText,
      isPlaying: isPlaying ?? this.isPlaying,
      isActive: isActive ?? this.isActive,
      events: events ?? List.from(this.events),
    );
  }

  ///Clear recording.
  void clear() {
    totalTimeMilliSec = 0;
    events.clear();
  }

  // void toggleLoop() {
  //   this.isLoop = !this.isLoop;
  // }

  String loopToString() => this.isLoop ? '1' : '0';
}
