import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/midi.dart';

class Recorder extends ChangeNotifier {
  Classroom classroom;
  List<RecEvent> _events = [];
  RecFile? currentRecord;
  int startTime = 0;
  int totalTime = 0;
  final int milliSecDivide = 10;
  bool isRecording = false;
  // bool isRenaming = false;
  var recordTimer;
  int recordingTime = 0;
  String recordCountDownText = kMaxRecordInSecText;
  var playBackTimer;
  int playBackingTime = 0;
  String playbackCountDownText = '0:00';
  var player;
  // bool isPlaying = false;

  Recorder(this.classroom);

  Future start() async {
    print('START');
    if (_events.isEmpty) {
      // New record
      _clearParams();
      startTime = DateTime.now().millisecondsSinceEpoch;
      this.isRecording = true;
      Setting.isRecording = true;
    } else {
      // Overwrite?

      // If OK
      _clearParams();
      startTime = DateTime.now().millisecondsSinceEpoch;
      this.isRecording = true;
      Setting.isRecording = true;
    }
    notifyListeners();
    _recTimer();
  }

  void _recTimer() {
    recordTimer = Timer.periodic(Duration(seconds: 1), (t) async {
      recordingTime++;
      _recCountDownText();
      notifyListeners();
      print('record clock: $recordingTime');
      if (recordingTime == kMaxRecordInSec) {
        stop();
      }
    });
  }

  void _recCountDownText() {
    int _availSec = kMaxRecordInSec - recordingTime;
    if (_availSec < 0) _availSec = 0;
    recordCountDownText = '0:${_availSec.toString().padLeft(2, '0')}';
  }

  void _clearParams() {
    _events.clear();
    currentRecord?.clear();
    startTime = 0;
    totalTime = 0;
  }

  void record({required List<int> raw}) {
    // int _now = DateTime.now().millisecondsSinceEpoch;
    // int _deltaTime = (_now - startTime) ~/ milliSecDivide;
    int _deltaTime = (DateTime.now().millisecondsSinceEpoch - startTime);
    _events.add(RecEvent(time: _deltaTime, data: raw));
  }

  void stop() {
    recordTimer?.cancel();
    recordingTime = 0;
    _recCountDownText();
    totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
    int _inSec = totalTime ~/ 1000;
    playbackCountDownText = '0:${_inSec.toString().padLeft(2, '0')}';
    currentRecord = RecFile(
      totalTimeMilliSec: totalTime,
      totalTimeSec: _inSec,
      totalTimeSecText: playbackCountDownText,
      events: _events,
    );
    this.isRecording = false;
    Setting.isRecording = false;
    print(
        'TOTAL: ${currentRecord!.totalTimeMilliSec} / ${currentRecord!.events.length}');
    // isRenaming = true;
    notifyListeners();
  }

  void clear() {
    _clearParams();
    notifyListeners();
  }

  Future play_start(RecFile file) async {
    List<RecEvent> _play = List.from(currentRecord!.events);

    int i = 0;
    player?.cancel;
    file.isPlaying = true;
    notifyListeners();
    _playBackTimer();
    player = Timer.periodic(Duration(milliseconds: milliSecDivide), (t) async {
      if (_play.isNotEmpty) {
        if (_play[0].time <= i) {
          final Uint8List _uintData = Uint8List.fromList(_play[0].data);
          classroom.sendLocal(_uintData,
              withSound: true, withLight: true, withMaster: true);
          _play.removeAt(0);
        }
      }
      if (i >= currentRecord!.totalTimeMilliSec) {
        t.cancel();
        file.isPlaying = false;
        _resetPlaybackTimer();
        classroom.resetDisplay();
        notifyListeners();
        print('FINISHED');
      }
      i = i + milliSecDivide;
    });
  }

  void _playBackTimer() {
    playBackTimer = Timer.periodic(Duration(seconds: 1), (t) async {
      playBackingTime++;
      _playBackCountDownText();
      notifyListeners();
      if (recordingTime == currentRecord!.totalTimeMilliSec) {
        t.cancel();
      }
    });
  }

  void _playBackCountDownText() {
    int _availSec = currentRecord!.totalTimeSec - playBackingTime;
    if (_availSec < 0) _availSec = 0;
    playbackCountDownText = '0:${_availSec.toString().padLeft(2, '0')}';
  }

  void _resetPlaybackTimer() {
    playBackTimer.cancel();
    playBackingTime = 0;
    playbackCountDownText = currentRecord!.totalTimeSecText;
  }

  void play_stop(RecFile file) {
    print('stop');
    player?.cancel();
    _resetPlaybackTimer();
    file.isPlaying = false;
    classroom.resetDisplay();
    notifyListeners();
  }

  void toggleRename(RecFile file) {
    file.isEditingName = !file.isEditingName;
    notifyListeners();
  }

  Future saveNewRecord() async {
    //Convert to string
    String _new = _fileToString(currentRecord!);
    print(_new);
    //Save string to device
  }

  String _fileToString(RecFile file) {
    String _new = '';
    _new += file.name + '||';
    _new += file.totalTimeMilliSec.toString() + '||';
    _new += file.totalTimeSec.toString() + '||';
    _new += file.totalTimeSecText + '||';
    for (int i = 0; i < file.events.length; i++) {
      _new += file.events[i].time.toString() + '||';
      String _shortenMidi = Setting.messageEncryptor(raw: file.events[i].data);
      _new += _shortenMidi + '||';
    }
    return _new;
  }

  // /// Encrypt outgoing message from MIDI[Uint8List] to [double]
  // /// Key's pressure as decimal place. (99 maximum)
  // String _messageEncryptor({required List<int> raw}) {
  //   int _switch = raw[kSwitchPos];
  //   int _note = raw[kKeyPos];
  //   late double _out;
  //   if (_switch == kNoteOn) {
  //     double _pressure = raw[kPressurePos] / 1000;
  //     _pressure >= 1 ? _pressure = 0.999 : _pressure = _pressure;
  //     _out = _switch + _note + _pressure;
  //   } else {
  //     _out = _note.roundToDouble();
  //   }
  //   return _out.toString();
  // }
}

///BACKUP
// import 'package:flutter/foundation.dart';
// import 'dart:typed_data';
// import 'dart:async';
// import 'package:everlong/models/recorder_file.dart';
// import 'package:everlong/services/classroom.dart';
// import 'package:everlong/services/setting.dart';
// import 'package:everlong/utils/constants.dart';
//
// class Recorder extends ChangeNotifier {
//   Classroom classroom;
//   List<RecEvent> events = [];
//   RecFile? file;
//   int startTime = 0;
//   int totalTime = 0;
//   final int milliSecDivide = 10;
//   bool isRecording = false;
//   bool isRenaming = false;
//   var recordTimer;
//   int recordingTime = 0;
//   String recordCountDownText = kMaxRecordInSecText;
//   var playBackTimer;
//   int playBackingTime = 0;
//   String playbackCountDownText = '0:00';
//   var player;
//   bool isPlaying = false;
//
//   Recorder(this.classroom);
//
//   Future start() async {
//     print('START');
//     if (events.isEmpty) {
//       // New record
//       _clearParams();
//       startTime = DateTime.now().millisecondsSinceEpoch;
//       this.isRecording = true;
//       Setting.isRecording = true;
//     } else {
//       // Overwrite?
//
//       // If OK
//       _clearParams();
//       startTime = DateTime.now().millisecondsSinceEpoch;
//       this.isRecording = true;
//       Setting.isRecording = true;
//     }
//     notifyListeners();
//     _recTimer();
//   }
//
//   void _recTimer() {
//     recordTimer = Timer.periodic(Duration(seconds: 1), (t) async {
//       recordingTime++;
//       _recCountDownText();
//       notifyListeners();
//       print('record clock: $recordingTime');
//       if (recordingTime == kMaxRecordInSec) {
//         stop();
//       }
//     });
//   }
//
//   void _recCountDownText() {
//     int _availSec = kMaxRecordInSec - recordingTime;
//     if (_availSec < 0) _availSec = 0;
//     recordCountDownText = '0:${_availSec.toString().padLeft(2, '0')}';
//   }
//
//   void _clearParams() {
//     events.clear();
//     file?.clear();
//     startTime = 0;
//     totalTime = 0;
//   }
//
//   void record({required List<int> raw}) {
//     int _now = DateTime.now().millisecondsSinceEpoch;
//     // int _deltaTime = (_now - startTime) ~/ milliSecDivide;
//     int _deltaTime = (_now - startTime);
//     events.add(RecEvent(time: _deltaTime, data: raw));
//     print(events.length);
//   }
//
//   void stop() {
//     recordTimer?.cancel();
//     recordingTime = 0;
//     _recCountDownText();
//     totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
//     int _inSec = totalTime ~/ 1000;
//     playbackCountDownText = '0:${_inSec.toString().padLeft(2, '0')}';
//     file = RecFile(
//       totalTimeMilliSec: totalTime,
//       totalTimeSec: _inSec,
//       totalTimeSecText: playbackCountDownText,
//       events: events,
//     );
//     this.isRecording = false;
//     Setting.isRecording = false;
//     print('TOTAL: ${file!.totalTimeMilliSec} / ${file!.events.length}');
//     isRenaming = true;
//     notifyListeners();
//   }
//
//   void clear() {
//     _clearParams();
//     notifyListeners();
//   }
//
//   Future play_start() async {
//     List<RecEvent> _play = List.from(file!.events);
//
//     int i = 0;
//     player?.cancel;
//     isPlaying = true;
//     notifyListeners();
//     _playBackTimer();
//     player = Timer.periodic(Duration(milliseconds: milliSecDivide), (t) async {
//       if (_play.isNotEmpty) {
//         if (_play[0].time <= i) {
//           final Uint8List _uintData = Uint8List.fromList(_play[0].data);
//           classroom.sendLocal(_uintData,
//               withSound: true, withLight: true, withMaster: true);
//           _play.removeAt(0);
//         }
//       }
//       if (i >= file!.totalTimeMilliSec) {
//         t.cancel();
//         isPlaying = false;
//         _resetPlaybackTimer();
//         classroom.resetDisplay();
//         notifyListeners();
//         print('FINISHED');
//       }
//       i = i + milliSecDivide;
//     });
//   }
//
//   void _playBackTimer() {
//     playBackTimer = Timer.periodic(Duration(seconds: 1), (t) async {
//       playBackingTime++;
//       _playBackCountDownText();
//       notifyListeners();
//       if (recordingTime == file!.totalTimeMilliSec) {
//         t.cancel();
//       }
//     });
//   }
//
//   void _playBackCountDownText() {
//     int _availSec = file!.totalTimeSec - playBackingTime;
//     if (_availSec < 0) _availSec = 0;
//     playbackCountDownText = '0:${_availSec.toString().padLeft(2, '0')}';
//   }
//
//   void _resetPlaybackTimer() {
//     playBackTimer.cancel();
//     playBackingTime = 0;
//     playbackCountDownText = file!.totalTimeSecText;
//   }
//
//   void play_stop() {
//     print('stop');
//     player?.cancel();
//     _resetPlaybackTimer();
//     isPlaying = false;
//     classroom.resetDisplay();
//     notifyListeners();
//   }
//
//   void toggleRename() {
//     isRenaming = !isRenaming;
//     notifyListeners();
//   }
// }
