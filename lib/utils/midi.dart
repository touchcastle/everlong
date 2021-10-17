import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';

final Guid kMIDIService = Guid('03B80E5A-EDE8-4B33-A751-6CE34EC4C700');
final Guid kMIDICharacteristic = Guid('7772E5DB-3868-4112-A1A9-F2669D106BF3');

/// Volume
const int kMinVol = 1;
const int kNormalVol = 60;

/// Note on/off as per MIDI standard.
const int kNoteOn = 144;
const int kNoteOff = 128;

/// Index of incoming message for key and note on/off.
const int kPressurePos = 4;
const int kKeyPos = 3;
const int kSwitchPos = 2;

/// By Manufacturer.
const int kLightOff = 0;
const int kLightOnRed = 1;
const int kLightOnRedPopPiano = 17;
// const int kLightOff = 00;
// const int kLightOnRed = 01;x
const int kLightOnBlue = 2;

const int kMidCKey = 60;
const int kFirstKey = 21; // For 88 keys device.
const int kLastKey = 108; // For 88 keys device.

/// Flat keys
final List<int> kIsFlat = [
  22,
  27,
  34,
  39,
  46,
  51,
  58,
  63,
  70,
  75,
  82,
  87,
  94,
  99,
  106,
];

/// There are 2 leading indexes[0,1] with code 128 for both in & out message.
/// (apply to Flutter_blue).
const int k128 = 128;
final Uint8List kMidCSound =
    Uint8List.fromList([k128, k128, kNoteOn, kMidCKey, kNormalVol]);
final Uint8List kAwakeMIDI =
    Uint8List.fromList([k128, k128, kNoteOn, kMidCKey, kMinVol]);

/// Message for light. (Need to update index 7,8 when use).
final Uint8List kLightMessage =
    Uint8List.fromList([k128, k128, 240, 77, 76, 78, 69, 0, 0, 247]);
final Uint8List kLightMessagePopPiano =
    Uint8List.fromList([k128, k128, 240, 77, 76, 78, 69, 0, 0, 128, 247]);
const int kLightKeyIndex = 7;
const int kLightSwitchIndex = 8;

final Uint8List kStart1 = Uint8List.fromList([1, 0]);
final Uint8List kStart2 = Uint8List.fromList(
    [k128, k128, 240, 15, 51, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
final Uint8List kStart2_2 = Uint8List.fromList(
    [k128, k128, 240, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
final Uint8List kStart3 =
    Uint8List.fromList([k128, k128, 241, 5, 51, 22, 0, 0, 0, 247]);
final Uint8List kStart4 =
    Uint8List.fromList([k128, k128, 240, 12, 01, 115, 126, 128, 247]);
final Uint8List kStart5 =
    Uint8List.fromList([240, 0, 103, 101, 116, 1, 6, 0, 247]);

/// Designated keys to light up during ping.
final Uint8List kIdentLight = Uint8List.fromList([21, 41, 64, 84, 106]);

/// Delay between each notes[kNoteDelayMillisec] if user press keys simultaneously.
/// more than [kAsChord] keys.
const int kNoteDelayMillisec = 30;
// const int kAsChord = 3;
