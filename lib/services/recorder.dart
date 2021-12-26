import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:nanoid/nanoid.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/views/record_rename.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/errors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

enum FileType {
  recording,
  stored,
}

class Recorder extends ChangeNotifier {
  Classroom classroom;
  List<RecEvent> recordingEvents = [];
  RecFile? currentRecord;
  int startTime = 0;
  int totalTime = 0;
  final int milliSecDivide = 60;
  bool isRecording = false;

  // bool isRenaming = false;
  var recordTimer;
  int recordingTime = 0;
  String recordCountDownText = kMaxRecordInSecText;
  var playBackTimer;
  int playBackingTime = 0;

  // String playbackCountDownText = '0:00';
  var player;
  List<RecFile> storedRecords = [];

  // bool isPlaying = false;

  Recorder(this.classroom);

  void init() {
    _getFromPrefs();
  }

  void _getFromPrefs() {
    storedRecords.clear();
    if (Setting.prefsRecords != null && Setting.prefsRecords!.length > 0) {
      for (int i = 0; i < Setting.prefsRecords!.length; i++) {
        RecFile _append = StringToFile(Setting.prefsRecords![i]);
        storedRecords.add(_append);
      }
    }
  }

  String downloadSharedRecord(String data) {
    RecFile _new = StringToFile(data);

    //add only new
    if (storedRecords.indexWhere((e) => e.id == _new.id) < 0) {
      saveRecord(_new);
      return 'record ${_new.name} saved.';
    } else {
      return 'record ${_new.name} is already stored';
    }
  }

  Future start(BuildContext context) async {
    print('START');
    if (recordingEvents.isEmpty) {
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
    _recTimer(context);
  }

  void _recTimer(BuildContext context) {
    recordTimer = Timer.periodic(Duration(seconds: 1), (t) async {
      recordingTime++;
      _recCountDownText();
      notifyListeners();
      print('record clock: $recordingTime');
      if (recordingTime == kMaxRecordInSec) {
        stop(context);
      }
    });
  }

  void _recCountDownText() {
    int _availSec = kMaxRecordInSec - recordingTime;
    if (_availSec < 0) _availSec = 0;
    recordCountDownText = '0:${_availSec.toString().padLeft(2, '0')}';
  }

  void _clearParams() {
    recordingEvents.clear();
    currentRecord?.clear();
    startTime = 0;
    totalTime = 0;
  }

  void record({required List<int> raw}) {
    int _deltaTime = (DateTime.now().millisecondsSinceEpoch - startTime);
    recordingEvents.add(RecEvent(time: _deltaTime, data: raw));
  }

  Future stop(BuildContext context) async {
    recordTimer?.cancel();
    recordingTime = 0;
    _recCountDownText();
    if (recordingEvents.length > 0) {
      totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
      int _inSec = totalTime ~/ 1000;
      String _timeText = '0:${_inSec.toString().padLeft(2, '0')}';
      String _id = customAlphabet(kRecordIdAlphabet, kRecordIdLength);
      List<RecEvent> _clone = List.from(recordingEvents);
      currentRecord = new RecFile(
        id: _id,
        totalTimeMilliSec: totalTime,
        totalTimeSec: _inSec,
        totalTimeSecText: _timeText,
        events: _clone,
      );
      await showDialog(
        context: context,
        builder: (BuildContext context) => dialogBox(
          context: context,
          content: RecordRenameDialog(
              fileType: FileType.recording, file: currentRecord!),
        ),
      );
    } else {
      Snackbar.show(
        Setting.currentContext!,
        text: '$kError: $kRecordNoMidi',
        icon: kBluetoothIconDisconnected,
        actionLabel: kOk,
      );
    }
    this.isRecording = false;
    Setting.isRecording = false;
    notifyListeners();
    // await showDialog(
    //   context: context,
    //   builder: (BuildContext context) => dialogBox(
    //     context: context,
    //     content: RecordRenameDialog(file: currentRecord!),
    //   ),
    // );
  }

  void clear() {
    _clearParams();
    notifyListeners();
  }

  Future playback_start(RecFile file) async {
    // List<RecEvent> _play = List.from(currentRecord!.events);
    List<RecEvent> _play = List.from(file.events);
    int i = 0;
    player?.cancel;
    file.isPlaying = true;
    notifyListeners();
    _playBackTimer(file);
    bool _continue = false;
    print('start playback with $milliSecDivide millisec');
    player = Timer.periodic(Duration(milliseconds: milliSecDivide), (t) {
      if (_play.isNotEmpty) {
        do {
          if (_play.length > 0 && _play[0].time <= i) {
            final Uint8List _uintData = Uint8List.fromList(_play[0].data);
            classroom.sendLocal(
              _uintData,
              withSound: true,
              withLight: true,
              withMaster: true,
            );
            _play.removeAt(0);
            // if (_continue) print('repeated within 1 period');
            _continue = true;
          } else {
            _continue = false;
          }
        } while (_continue);
      }
      // if (i >= currentRecord!.totalTimeMilliSec) {
      if (i >= file.totalTimeMilliSec) {
        t.cancel();
        file.isPlaying = false;
        _resetPlaybackTimer(file);
        classroom.resetDisplay();
        notifyListeners();
        print('FINISHED');
      }
      i = i + milliSecDivide;
    });
  }

  void _playBackTimer(RecFile file) {
    playBackTimer = Timer.periodic(Duration(seconds: 1), (t) async {
      playBackingTime++;
      _playBackCountDownText(file);
      notifyListeners();
      if (playBackingTime == file.totalTimeSec) {
        t.cancel();
      }
    });
  }

  void _playBackCountDownText(RecFile file) {
    // int _availSec = currentRecord!.totalTimeSec - playBackingTime;
    int _availSec = file.totalTimeSec - playBackingTime;
    if (_availSec < 0) _availSec = 0;
    file.totalTimeSecText = '0:${_availSec.toString().padLeft(2, '0')}';
  }

  void _resetPlaybackTimer(RecFile file) {
    playBackTimer.cancel();
    playBackingTime = 0;
    file.totalTimeSecText = '0:${file.totalTimeSec.toString().padLeft(2, '0')}';
    // playbackCountDownText = currentRecord!.totalTimeSecText;
  }

  void playback_stop(RecFile file) {
    print('stop');
    player?.cancel();
    _resetPlaybackTimer(file);
    file.isPlaying = false;
    classroom.resetDisplay();
    notifyListeners();
  }

  void renameRecord(RecFile file, String newName, FileType fileType) {
    if (newName == '' ||
        newName.contains('|') ||
        newName.contains('<') ||
        newName.contains('>')) {
      throw kErr1008;
    } else {
      file.name = newName;

      if (fileType == FileType.stored) {
        //Get current index for further insert.
        int _prefIndex = Setting.prefsRecords!.indexWhere(
            (item) => item.substring(0, kRecordIdLength) == file.id);

        //Delete in in-app pref
        Setting.prefsRecords!.removeAt(_prefIndex);

        //Convert new to string
        String _asString = fileToString(file);

        //Insert new file(new name) at same index as before.
        Setting.prefsRecords!.insert(_prefIndex, _asString);

        //Update prefs
        Setting.saveListString(kRecordsPref, Setting.prefsRecords!);
      }
      notifyListeners();
    }
  }

  void toggleRename(RecFile file) {
    file.isEditingName = !file.isEditingName;
    notifyListeners();
  }

  String _activeNow = '';

  void toggleActive(RecFile file) {
    if (_activeNow != '' && file.id != _activeNow) {
      //cancel old active
      int i = storedRecords.indexWhere((item) => item.id == _activeNow);
      if (i >= 0) storedRecords[i].isActive = false;
    }
    file.isActive = !file.isActive;
    file.isActive ? _activeNow = file.id : _activeNow = '';

    notifyListeners();
  }

  void saveRecord(RecFile file) {
    //Append to in-app record list
    RecFile _clone = file.copyWith();
    storedRecords.add(_clone);

    //Convert to string
    String _asString = fileToString(file);

    //Append to in-app prefs list
    Setting.prefsRecords?.add(_asString);

    //Update prefs
    Setting.saveListString(kRecordsPref, Setting.prefsRecords!);

    //Clear current record after saved
    clear();
    notifyListeners();
  }

  void deleteRecord(String recordId) {
    storedRecords.removeWhere((item) => item.id == recordId);
    Setting.prefsRecords
        ?.removeWhere((item) => item.substring(0, kRecordIdLength) == recordId);

    //Update prefs
    Setting.saveListString(kRecordsPref, Setting.prefsRecords!);

    notifyListeners();
  }

  String fileToString(RecFile file) {
    String _new = '';

    //HEADER
    //[0]
    _new += file.id + kRecordHeaderDivider;

    //[1]
    _new += file.name + kRecordHeaderDivider;

    //[2]
    _new += file.totalTimeMilliSec.toString() + kRecordHeaderDivider;

    //[3]
    _new += file.totalTimeSec.toString() + kRecordHeaderDivider;

    //[4]
    _new += file.totalTimeSecText + kRecordHeaderDivider;

    //ITEMS
    //[5]
    for (int i = 0; i < file.events.length; i++) {
      _new += file.events[i].time.toString() + kRecordEventDivider;
      String _shortenMidi = Setting.messageEncryptor(raw: file.events[i].data);
      if (i < (file.events.length - 1)) {
        _new += _shortenMidi + kRecordItemDivider;
      } else if (i == (file.events.length - 1)) {
        _new += _shortenMidi;
      }
    }

    return _new;
  }

  RecFile StringToFile(String string) {
    print('incoming: $string');
    List<RecEvent> _RecordEvents = [];

    List<String> _header = string.split(kRecordHeaderDivider);
    print('header: $_header');
    List<String> _items = _header[5].split(kRecordItemDivider);
    print('item: ${_items.length}');

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].length > 0) {
        List<String> _events = _items[i].split(kRecordEventDivider);
        RecEvent _append = RecEvent(
          time: int.parse(_events[0]),
          data: Setting.messageDecryptor(raw: double.parse(_events[1])),
        );
        _RecordEvents.add(_append);
      }
    }
    RecFile _out = RecFile(
      id: _header[0],
      name: _header[1],
      totalTimeMilliSec: int.parse(_header[2]),
      totalTimeSec: int.parse(_header[3]),
      totalTimeSecText: _header[4],
      events: _RecordEvents,
      isEditingName: false,
    );
    return _out;
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
