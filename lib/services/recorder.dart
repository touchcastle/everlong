import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:nanoid/nanoid.dart';
import 'package:everlong/models/recorder_file.dart';
import 'package:everlong/services/classroom.dart';
import 'package:everlong/services/setting.dart';
import 'package:everlong/ui/views/record/record_rename.dart';
import 'package:everlong/ui/widgets/dialog.dart';
import 'package:everlong/ui/widgets/snackbar.dart';
import 'package:everlong/utils/constants.dart';
import 'package:everlong/utils/errors.dart';
import 'package:everlong/utils/icons.dart';
import 'package:everlong/utils/texts.dart';

///When working with recorder file. There are 2 types of file.
enum FileType {
  ///1) File that just finished record but still don't saved in list and memory.
  recording,

  ///2) File stored in memory and in-app list.
  stored,
}

///Class for recording new file and manage with recorded file.
class Recorder extends ChangeNotifier {
  Classroom classroom;

  ///List of each note in particular timestamp during new recording.
  List<RecEvent> recordingEvents = [];

  ///New recorded file.
  RecFile? currentRecord;

  ///Temp variable for record event timestamp.
  int startTime = 0;
  int totalTime = 0;

  ///Interval time for playback function.
  final int milliSecDivide = 60;

  ///Periodic playback variable.
  var player;

  bool isRecording = false;

  ///For recording duration display.
  var recordingTimer;
  int recordingTime = 0;
  String recordingTimerText = kMaxRecordInSecText;

  ///For playback duration display.
  var playBackTimer;
  int playBackingTime = 0;

  ///List of records that stored in memory(will sync between memory and this
  ///in-app list).
  List<RecFile> storedRecords = [];

  Recorder(this.classroom);

  ///Initialize recorder
  void init() {
    _getFromPrefs();
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// RECORD MOVEMENT
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///Get list of stored records from memory(String) and sync to in-app list.
  void _getFromPrefs() {
    storedRecords.clear();
    if (Setting.prefsRecords != null && Setting.prefsRecords!.length > 0) {
      //Convert all memory records(String) into workable data type.
      for (int i = 0; i < Setting.prefsRecords!.length; i++) {
        RecFile _append = StringToFile(Setting.prefsRecords![i]);
        storedRecords.add(_append);
      }
    }
  }

  ///[data] is record stored in cloud as string.
  ///convert string into workable data type then save.
  ///Check whether this record is already in app.
  String downloadSharedRecord(String data) {
    RecFile _new = StringToFile(data);
    if (storedRecords.indexWhere((e) => e.id == _new.id) < 0) {
      saveRecord(_new);
      return 'record ${_new.name} was saved.';
    } else {
      return 'record ${_new.name} was already stored';
    }
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// NEW RECORD
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///Start new record and start countdown recorder timer.
  ///
  /// [Setting.isRecording] is for bluetooth piano's logic.
  Future start(BuildContext context) async {
    if (recordingEvents.isEmpty) {
      // New record
      _clearRecording();
      startTime = DateTime.now().millisecondsSinceEpoch;
      this.isRecording = true;
      Setting.isRecording = true;
    } else {
      // Overwrite?

      // If OK
      _clearRecording();
      startTime = DateTime.now().millisecondsSinceEpoch;
      this.isRecording = true;
      Setting.isRecording = true;
    }
    notifyListeners();

    //Countdown recorder timer.
    _recTimer(context);
  }

  void _clearRecording() {
    recordingEvents.clear();
    currentRecord?.clear();
    startTime = 0;
    totalTime = 0;
  }

  ///Recorder timer.
  void _recTimer(BuildContext context) {
    recordingTimer = Timer.periodic(Duration(seconds: 1), (t) async {
      recordingTime++;
      _recCountDownText();
      notifyListeners();
      if (recordingTime == kMaxRecordInSec) stop(context);
    });
  }

  ///Prepare recorder timer text [recordingTimerText].
  ///this variable will be use to display.
  void _recCountDownText() {
    int _availSec = kMaxRecordInSec - recordingTime;
    if (_availSec < 0) _availSec = 0;
    recordingTimerText = '0:${_availSec.toString().padLeft(2, '0')}';
  }

  ///Retrieve MIDI data from bluetooth device then add to events list with
  ///timestamp.
  void record({required List<int> raw}) {
    int _deltaTime = (DateTime.now().millisecondsSinceEpoch - startTime);
    recordingEvents.add(RecEvent(time: _deltaTime, data: raw));
  }

  ///Stop record, prepare variables with generated UUID for further use.
  ///then prompt dialog for set name.
  ///
  ///Will only allow if at least 1 event(MIDI note) was found.
  Future stop(BuildContext context) async {
    recordingTimer?.cancel();
    recordingTime = 0;

    //This will refresh recording timer.
    _recCountDownText();

    if (recordingEvents.length > 0) {
      //Duration
      totalTime = DateTime.now().millisecondsSinceEpoch - startTime;
      int _inSec = totalTime ~/ 1000;
      String _timeText = '0:${_inSec.toString().padLeft(2, '0')}';

      //Generate UUID
      String _id = customAlphabet(kRecordIdAlphabet, kRecordIdLength);

      List<RecEvent> _clone = List.from(recordingEvents);
      currentRecord = new RecFile(
        id: _id,
        totalTimeMilliSec: totalTime,
        totalTimeSec: _inSec,
        totalTimeSecText: _timeText,
        events: _clone,
      );

      //Prompt dialog for set name.
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
  }

  ///To clear current recorded file.
  void clear() {
    _clearRecording();
    notifyListeners();
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// PLAYBACK
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///Start playback for [file]
  Future playback_start(RecFile file) async {
    List<RecEvent> _play = List.from(file.events);
    int _timeCursor = 0;

    //Cancel if any playing.
    player?.cancel;

    file.isPlaying = true;
    notifyListeners();

    //Run playback timer.
    _playBackTimer(file);

    bool _continue = false;
    player = Timer.periodic(Duration(milliseconds: milliSecDivide), (t) {
      if (_play.isNotEmpty) {
        do {
          if (_play.length > 0 && _play[0].time <= _timeCursor) {
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

      //Move time cursor
      _timeCursor += milliSecDivide;

      //When playing completed(Time cursor >= file duration).
      if (_timeCursor >= file.totalTimeMilliSec) {
        t.cancel();
        file.isPlaying = false;
        _resetPlaybackTimer(file);
        classroom.resetDisplay();
        notifyListeners();
        print('FINISHED');
      }
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

  ///Stop current playback.
  void playback_stop(RecFile file) {
    print('stop');
    player?.cancel();
    _resetPlaybackTimer(file);
    file.isPlaying = false;
    classroom.resetDisplay();
    notifyListeners();
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// RECORD'S ACTION
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///Rename record[file] with [newName].
  ///If rename just' recorded file type[FileType.recording]. -> just rename.
  ///But if rename stored file[FileType.stored]. -> also need to update list
  ///in device's memory(prefs).
  void renameRecord(RecFile file, String newName, FileType fileType) {
    if (newName == '' ||
        newName.contains('|') ||
        newName.contains('<') ||
        newName.contains('>')) {
      throw kErr1008;
    } else {
      //Update in-app file name.
      file.name = newName;

      //Modify and update file in mobile's memory(prefs).
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

  ///Since user needs to click on specific record prior to do anything with that
  ///record. App will need to mark flag for active record for display purpose.
  void toggleActive(RecFile file) {

    //Check "before toggle" status. for any currently active record that needs
    //to be canceled first.
    if (file.isActive) {
      //Just cancel
      file.isActive = false;
    } else {
      //Cancel other(if any) before mark this one.
      int i = storedRecords
          .indexWhere((item) => item.id != file.id && item.isActive);
      if (i >= 0) storedRecords[i].isActive = false;
      file.isActive = true;
    }
    notifyListeners();
  }

  ///There are 3 variables that storing records
  ///(same files but different type and place)
  ///1.[storedRecords] as [RecFile] type. (ready for playback)
  ///2.[Setting.prefsRecords] as [String] for working with device's memory.
  ///3.[kRecordsPref] in device's memory that need to Get() or Set().
  ///
  ///Save new recorded to in-app list and device's memory(pref).
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

  ///Delete record from in-app list and device's memory(pref).
  void deleteRecord(String recordId) {
    storedRecords.removeWhere((item) => item.id == recordId);

    Setting.prefsRecords
        ?.removeWhere((item) => item.substring(0, kRecordIdLength) == recordId);

    //Update prefs
    Setting.saveListString(kRecordsPref, Setting.prefsRecords!);

    notifyListeners();
  }

  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  /// CONVERTER
  ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ///
  ///To convert record from [RecFile] to [String].
  ///
  ///HAS INDEX HARDCODED!
  String fileToString(RecFile file) {
    String _new = '';

    //----------------
    //HEADER
    //----------------
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

    //----------------
    //EVENTS
    //----------------
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

  ///To convert record from [String] to [RecFile].
  ///
  ///HAS INDEX HARDCODED!
  RecFile StringToFile(String string) {
    List<RecEvent> _RecordEvents = [];

    //Will get Header data(s) + Events
    List<String> _header = string.split(kRecordHeaderDivider);

    //Will get list of events (Still as string)
    List<String> _events = _header[5].split(kRecordItemDivider);

    //Append each string event into list of <RecEvent>.
    for (int i = 0; i < _events.length; i++) {
      if (_events[i].length > 0) {
        List<String> _event = _events[i].split(kRecordEventDivider);
        RecEvent _append = RecEvent(
          time: int.parse(_event[0]),
          data: Setting.messageDecryptor(raw: double.parse(_event[1])),
        );
        _RecordEvents.add(_append);
      }
    }

    //Will get result as <RecFile>
    RecFile _out = RecFile(
      id: _header[0],
      name: _header[1],
      totalTimeMilliSec: int.parse(_header[2]),
      totalTimeSec: int.parse(_header[3]),
      totalTimeSecText: _header[4],
      events: _RecordEvents,
    );
    return _out;
  }
}
