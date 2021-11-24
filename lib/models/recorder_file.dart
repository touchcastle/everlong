import 'dart:typed_data';

class RecEvent {
  final int time;
  final Uint8List data;

  RecEvent({
    required this.time,
    required this.data,
  });
}

class RecFile {
  int totalTime;
  List<RecEvent> events;

  RecFile({required this.totalTime, required this.events});

  void clear(){
    totalTime = 0;
    events.clear();
  }
}
