import 'package:flutter/foundation.dart';
import 'package:everlong/models/staff.dart';
import 'package:everlong/utils/midi.dart';

class Staff extends ChangeNotifier {
  /// Staff storage
  static List<StaffStore> staffList = [];

  /// Generate list that contain only Major notes along with parameter
  /// for Sharp, Flat and indicator when user press keys on/off
  static List<StaffStore> genStaffList() {
    List<StaffStore> _staffList = [];
    // int _note = 36;
    int _note = 21;
    int _time = 2;
    int _increase = 2;
    int _switch = 3;
    for (int i = 1; i <= 56; i++) {
      _staffList.add(StaffStore(note: _note));
      _note += _increase;
      _time++;
      if (_time < 1) {
        _increase == 2 ? _increase = 1 : _increase = 2;
      } else if (_time == _switch) {
        _switch == 2 ? _switch = 3 : _switch = 2;
        _increase == 2 ? _increase = 1 : _increase = 2;
        _time = -1;
      }
    }
    return _staffList;
  }

  /// Clear variable and list.
  static void resetDisplay() {
    staffList.clear();
    staffList = genStaffList();
  }

  /// To check that [note] is out of normal staff or not
  /// add [_outOfStaff] if out.
  /// [_replaceNote] is to display this note inside staff instead.
  /// [_outOfStaff] is for display function (Color, Text,...)
  /// Then pass parameters to 'storeStaff' function to check Flat / Sharp
  static void updateStaff(int note, int noteSwitch) {
    print('update staff with $note $noteSwitch');
    storeStaff(note, noteSwitch, 0);
  }

  /// To check whether [note] is flat / sharp note?
  /// 1. Check with pre-generate [staffList] which contains only major notes.
  /// 2. If not, check with [_isFlat] list for flat.
  /// 3. If not -> Sharp note.
  /// 4. [withNatural] is for case when natural note and sharp/flat note was
  /// pressed at the same time (eg. C + C#). (Flagged for display purpose)
  static void storeStaff(int note, int noteSwitch, int outOfStaff) {
    int _index = staffList.indexWhere((s) => s.note == note);
    // For major notes
    if (_index >= 0) {
      if (noteSwitch == kNoteOn) {
        if (staffList[_index].withSharp || staffList[_index].withFlat) {
          staffList[_index].withNatural = true;
        }
        staffList[_index].isOn = true;
        // staffList[_index].outOfStaff = outOfStaff;
      } else {
        if (staffList[_index].withSharp || staffList[_index].withFlat) {
          staffList[_index].withNatural = false;
        } else {
          staffList[_index].isOn = false;
          // staffList[_index].outOfStaff = 0;
        }
      }
    } else if (_index < 0) {
      // For sharp and flat notes
      if (kIsFlat.contains(note)) {
        // Flat of next note
        int _withFlat = staffList.indexWhere((s) => s.note == note + 1);
        if (_withFlat >= 0) {
          if (noteSwitch == kNoteOn) {
            if (staffList[_withFlat].isOn)
              staffList[_withFlat].withNatural = true;
            staffList[_withFlat].isOn = true;
            staffList[_withFlat].withFlat = true;
            // staffList[_withFlat].outOfStaff = outOfStaff;
          } else {
            if (staffList[_withFlat].withNatural) {
              staffList[_withFlat].withNatural = false;
              staffList[_withFlat].withFlat = false;
            } else {
              staffList[_withFlat].isOn = false;
              staffList[_withFlat].withFlat = false;
              // staffList[_withFlat].outOfStaff = 0;
            }
          }
        }
      } else {
        // Sharp of previous note
        int _withSharp = staffList.indexWhere((s) => s.note == note - 1);
        if (_withSharp >= 0) {
          if (noteSwitch == kNoteOn) {
            if (staffList[_withSharp].isOn)
              staffList[_withSharp].withNatural = true;
            staffList[_withSharp].isOn = true;
            staffList[_withSharp].withSharp = true;
            // staffList[_withSharp].outOfStaff = outOfStaff;
          } else {
            if (staffList[_withSharp].withNatural) {
              staffList[_withSharp].withNatural = false;
              staffList[_withSharp].withSharp = false;
            } else {
              staffList[_withSharp].isOn = false;
              staffList[_withSharp].withSharp = false;
              // staffList[_withSharp].outOfStaff = 0;
            }
          }
        }
      }
    }
    // notifyListeners();
  }
}
