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
  String id;
  String name;
  int totalTimeMilliSec;
  int totalTimeSec;
  String totalTimeSecText;
  bool isPlaying;
  bool isEditingName;
  bool isActive;
  List<RecEvent> events;

  RecFile({
    required this.id,
    required this.totalTimeMilliSec,
    required this.totalTimeSec,
    required this.totalTimeSecText,
    required this.events,
    this.isPlaying = false,
    this.isEditingName = false,
    this.isActive = false,
    this.name = 'New Record',
  });

  RecFile copyWith({
    String? id,
    String? name,
    int? totalTimeMilliSec,
    int? totalTimeSec,
    String? totalTimeSecText,
    bool? isPlaying,
    bool? isEditingName,
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
      isEditingName: isEditingName ?? this.isEditingName,
      isActive: isActive ?? this.isActive,
      events: events ?? List.from(this.events),
    );
  }

  void clear() {
    totalTimeMilliSec = 0;
    events.clear();
  }
}
