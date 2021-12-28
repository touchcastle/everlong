import 'package:everlong/models/piano.dart';
import 'package:flutter/material.dart';
import 'package:everlong/utils/midi.dart';

///Class for display pressing keys and also determine chord.
class Piano {
  /// Contains data for all 88 keys piano.
  List<PianoModel> keyList = [];

  /// Contains only current pressing keys for display and chord determine
  /// function.
  List<PianoModel> pressingKeyList = [];

  /// Current pressing chord
  String pressingChord = '';

  /// Generate list that contains value for all 88 keys piano with parameter
  /// for octave, signature and pressing flag for display function.
  /// [_virtual] is actual key's number from MIDI message.
  List<PianoModel> generateKeysList() {
    List<PianoModel> _keyList = [];
    for (int _index = 1; _index <= 88; _index++) {
      final int _virtual = _index + (kFirstKey - 1);
      late final int _octave;
      if (_index < 4) {
        _octave = -1;
      } else {
        _octave = ((_index - 3) / 12).ceil();
      }
      late final Note _note;
      late final Signature _sig;
      if ((_index - 1) % 12 == 0) {
        _note = Note.A;
        _sig = Signature.natural;
      }
      if ((_index - 2) % 12 == 0) {
        _note = Note.B;
        _sig = Signature.flat;
      }
      if ((_index - 3) % 12 == 0) {
        _note = Note.B;
        _sig = Signature.natural;
      }
      if ((_index - 4) % 12 == 0) {
        _note = Note.C;
        _sig = Signature.natural;
      }
      if ((_index - 5) % 12 == 0) {
        _note = Note.C;
        _sig = Signature.sharp;
      }
      if ((_index - 6) % 12 == 0) {
        _note = Note.D;
        _sig = Signature.natural;
      }
      if ((_index - 7) % 12 == 0) {
        _note = Note.E;
        _sig = Signature.flat;
      }
      if ((_index - 8) % 12 == 0) {
        _note = Note.E;
        _sig = Signature.natural;
      }
      if ((_index - 9) % 12 == 0) {
        _note = Note.F;
        _sig = Signature.natural;
      }
      if ((_index - 10) % 12 == 0) {
        _note = Note.F;
        _sig = Signature.sharp;
      }
      if ((_index - 11) % 12 == 0) {
        _note = Note.G;
        _sig = Signature.natural;
      }
      if ((_index - 12) % 12 == 0) {
        _note = Note.G;
        _sig = Signature.sharp;
      }
      _keyList.add(PianoModel(
          index: _index,
          note: _note,
          signature: _sig,
          octave: _octave,
          virtualKey: _virtual));
    }
    return _keyList;
  }

  /// [virtualKey] is actual key's number from MIDI message.
  /// Find corresponding key in [keyList] and add to [pressingKeyList].
  /// Then sort [pressingKeyList] ascending order by key's index.
  /// (Lower tone > Higher tone).
  void addPressing(int virtualKey) {
    final int _i = keyList.indexWhere((l) => l.virtualKey == virtualKey);
    if (_i >= 0) {
      pressingKeyList.add(keyList[_i]);
      keyList[_i].isPressing = true;
      // notifyListeners();
    }
    pressingKeyList.sort((a, b) => a.index.compareTo(b.index));
    pressingChord = checkChord(pressing: pressingKeyList);
  }

  /// When release(NoteOff) message, remove corresponding key from
  /// [pressingKeyList].
  void removePressing(int virtualKey) {
    final int _i = keyList.indexWhere((l) => l.virtualKey == virtualKey);
    if (_i >= 0) keyList[_i].isPressing = false;
    // notifyListeners();
    pressingKeyList.removeWhere((element) => element.virtualKey == virtualKey);
    pressingChord = checkChord(pressing: pressingKeyList);
  }

  /// For pressing keys in [pressing]. Find a chord.
  /// Since [pressing] (data from[pressingKeyList]) was ordered, This function
  /// find chord by lowest pressing keys first.
  /// When there is any chord found, function stop finding and return founded
  /// chord as result.
  String checkChord({required List<PianoModel> pressing}) {
    String _chord = '';
    if (pressing.length >= 3 && pressing.length <= 4) {
      for (PianoModel _root in pressing) {
        int _chordRoot = _root.index;
        int _second = _chordRoot + 2;
        bool _hasSecond = false;
        int _third = _chordRoot + 4;
        bool _hasThird = false;
        int _fourth = _chordRoot + 5;
        bool _hasFourth = false;
        int _thirdFlat = _chordRoot + 3;
        bool _hasThirdFlat = false;
        int _fifth = _chordRoot + 7;
        bool _hasFifth = false;
        int _sixth = _chordRoot + 9;
        bool _hasSixth = false;
        int _seventh = _chordRoot + 10;
        bool _hasSeventh = false;
        bool _gotChord = false;
        for (PianoModel _key in pressing.where((k) => k.index != _chordRoot)) {
          if (equivalentOf(_key.index, _second)) _hasSecond = true;
          if (equivalentOf(_key.index, _third)) _hasThird = true;
          if (equivalentOf(_key.index, _fourth)) _hasFourth = true;
          if (equivalentOf(_key.index, _thirdFlat)) _hasThirdFlat = true;
          if (equivalentOf(_key.index, _fifth)) _hasFifth = true;
          if (equivalentOf(_key.index, _sixth)) _hasSixth = true;
          if (equivalentOf(_key.index, _seventh)) _hasSeventh = true;
        }
        if (_hasFifth) {
          /// First, check for basic Major, Minor chord
          if (_hasThird) {
            _chord = majorChordText(_root);
            _gotChord = true;
          } else if (_hasThirdFlat) {
            _chord = majorChordText(_root);
            _chord += 'm';
            _gotChord = true;
          }

          /// If has only 3 keys, check for sus2,4
          if (pressing.length == 3) {
            if (_hasSecond) {
              _chord = majorChordText(_root);
              _chord += 'sus2';
              _gotChord = true;
            } else if (_hasFourth) {
              _chord = majorChordText(_root);
              _chord += 'sus4';
              _gotChord = true;
            }
          }

          /// If has 4 keys, check for other types of chord.
          if (pressing.length == 4) {
            if (_hasSixth && _gotChord) {
              _chord += '6';
              _gotChord = true;
            } else if (_hasSeventh && _gotChord) {
              _chord += '7';
              _gotChord = true;
            } else if (_hasSecond && _gotChord) {
              _chord += 'add9';
              _gotChord = true;
            } else {
              _chord = '';
              _gotChord = false;
            }
          }
          if (_gotChord) break;
        }
      }
    } else {
      _chord = '';
    }
    return _chord;
  }

  /// To check is 2 keys is same note but different octave.
  /// So, user can press correct notes but different octave to complete
  /// as a chord.
  bool equivalentOf(int a, int b) {
    bool _result = false;
    int _dif;
    a >= b ? _dif = a - b : _dif = b - a;
    if (_dif % 12 == 0) _result = true;
    return _result;
  }

  String majorChordText(PianoModel chord) {
    String _chordText = chord.note.toString().split('.').last;
    if (chord.signature != Signature.natural) {
      switch (chord.signature) {
        case Signature.sharp:
          _chordText += '#';
          break;
        case Signature.flat:
          _chordText += 'b';
          break;
        default:
          break;
      }
    }
    return _chordText;
  }

  /// To return pressing keys from [keys] into a String
  /// (C, D#, F)
  String pressingKeys(List<PianoModel> keys) {
    String _out = '';
    if (keys.length > 0) {
      for (int i = 0; i < keys.length; i++) {
        String _this = keys[i].note.toString().split('.').last;
        if (keys[i].signature != Signature.natural) {
          switch (keys[i].signature) {
            case Signature.sharp:
              _this += '#';
              break;
            case Signature.flat:
              _this += 'b';
              break;
            default:
              break;
          }
        }
        _this += '${keys[i].octave.toString()}';
        _out += ' $_this';
      }
    }
    return _out;
  }

  /// Reset virtual piano / pressing keys / chord display.
  void resetDisplay() {
    pressingKeyList.clear();
    pressingChord = '';
    for (int _i = 0; _i < keyList.length; _i++) {
      keyList[_i].isPressing = false;
    }
  }
}