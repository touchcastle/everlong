import 'package:flutter/material.dart';
import 'package:everlong/models/staff.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'dart:ui' as ui;
import 'package:everlong/utils/colors.dart';
import 'package:everlong/utils/styles.dart';

///Widget to display
///1. non-standard staff lines which will be display in 2 columns.
///   - left column will be wider than right column since its need to
///     display 2 columns of music notes inside of it.
///     (happen when pressing both natural and sharp/flat at the same time)
///2. red oval music notes.
///3. sharp/flat images in front of music notes.
Widget notesPainter(
  List<StaffStore> _playing,
  Size _size, {
  required KeySig keySig,
  required double width,
  required double height,
  ui.Image? imageSharp,
  ui.Image? imageFlat,
}) {
  double _clefArea() => width / kClefAreaProportion;
  return Container(
    color: Colors.transparent,
    width: width - _clefArea(),
    height: height,
    child: CustomPaint(
        foregroundPainter: NotePainter(_playing,
            keySig: keySig,
            imageSharp: imageSharp != null ? imageSharp : null,
            imageFlat: imageFlat != null ? imageFlat : null),
        size: _size),
  );
}

///Actual painter.
class NotePainter extends CustomPainter {
  final KeySig keySig;
  List<StaffStore> playing;
  final ui.Image? imageSharp;
  final ui.Image? imageFlat;
  NotePainter(
    this.playing, {
    required this.keySig,
    this.imageSharp,
    this.imageFlat,
  });

  ///Maximum display notes for each key.
  int _maxNotes() => keySig == KeySig.g ? 30 : 24;

  ///Use to correctly indexing notes in array.
  int _plusIndex() => keySig == KeySig.g ? 23 : 0;

  ///Last index of notes for each key.
  int _endIndex() => keySig == KeySig.g ? 30 : 24;

  ///Expanded length of non-standard staff.
  double _lineExpand = 0.8;

  ///Expanded length of left column staff.
  double _leftLineExpand() => keySig == KeySig.g ? 0.175 : 0.22;

  ///Padding for key signatures image display for correctly positioned.
  double _signatureTopPadding({required bool isSharp}) => isSharp ? 8.5 : 13.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paintNull = Paint()..color = Colors.transparent;

    ///Paint staff line.
    final paintLine = Paint()
      ..color = kStaffColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    ///Paint note.
    final paintNote = Paint()
      ..color = kNoteColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    ///Paint sharp/flat image.
    final paintSignature = Paint();

    ///Space between each note's line. (1 staff line has 2 note line)
    ///*has same calculation in view/screens/staffs.dart
    double _lineSpace() => size.height / 30;

    ///Position (x axis) of left displaying notes.
    double _leftNote() => (size.width / 2) - (size.width / 15);

    ///Position (x axis) of right displaying notes.
    double _rightNote() => (size.width / 2) + (size.width / 8);

    ///Space of natural note what will be display left of sharp/flat note
    ///in case user press natural and sharp/flat keys together.
    double _naturalNoteLeftIndent = size.width / 7;

    ///Space of natural note what will be display left of sharp/flat note
    ///in case user press natural and sharp/flat keys together.
    double _imageLeftIndent = 21;

    ///Calculate position in Y axis for each index of non-standard staff.
    ///*has same calculation in view/screens/staffs.dart
    double _staffYAxisPosition(int index) => this.keySig == KeySig.g
        ? _lineSpace() * index
        : _lineSpace() * index - _lineSpace();

    ///Calculate position in X axis for each index note.
    double _noteXAxisPosition(int index) => keySig == KeySig.g
        ? index.isOdd
            ? _leftNote()
            : _rightNote()
        : index.isEven
            ? _leftNote()
            : _rightNote();

    ///Calculate position in Y axis for each index of note.
    ///
    ///When painting notes, its start from the end of canvas, So I have to
    ///revert painting by has [size.height -] before calculation.
    ///
    ///With same index, If key G note is on the line, key F note will be between
    ///the line instead. So I have to minus another [_lineSpace()] for key F
    double _noteYAxisPosition(int index) => this.keySig == KeySig.g
        ? (size.height - (_lineSpace() * index))
        : (size.height - (_lineSpace() * index) - _lineSpace()) -
            (_lineSpace() * 6);

    ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ///PAINTER
    ///+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ///
    ///-------------------------------------------------------------------------
    ///NON-STANDARD STAFF PAINTER.
    ///-------------------------------------------------------------------------
    void _drawNonStandardStaff(int index, {required bool isLeft}) {
      ///Because left line should be longer than right line(Expand to the left
      ///from center), [_leftLineExpand()] will be use for this purpose.
      double _expander() => isLeft ? _leftLineExpand() : _lineExpand;

      ///Center point (X axis) for left/right line before expand.
      double _xAxisPoint() => isLeft ? _leftNote() : _rightNote();

      ///Draw to canvas fx.
      canvas.drawLine(
        Offset(_xAxisPoint() - ((size.width / _maxNotes()) / _expander()),
            _staffYAxisPosition(index)),
        Offset(_xAxisPoint() + ((size.width / _maxNotes()) / _lineExpand),
            _staffYAxisPosition(index)),
        keySig == KeySig.g
            ? index.isOdd
                ? paintLine
                : paintNull
            : index.isEven
                ? paintLine
                : paintNull,
      );
    }

    ///
    ///-------------------------------------------------------------------------
    ///PLAYING NOTES PAINTER.
    ///-------------------------------------------------------------------------
    ///Key G and F has different amount of notes, so [_endIndex()] will be use.
    ///
    ///If natural note and sharp/flat of the same note are pressed together,
    ///natural note(plaint oval) will be display at the left of sharp/flat note
    ///by [_leftIndent] pixel.
    void _drawOvalNote(
      int index, {
      required bool isOn,
      bool onLeft = false,
    }) {
      double _left() => onLeft ? _naturalNoteLeftIndent : 0;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(
              _noteXAxisPosition(index) - _left(),
              _noteYAxisPosition(index),
            ),
            width: size.height / 15,
            height: _lineSpace() + 1),
        isOn ? paintNote : paintNull,
      );
    }

    ///
    ///-------------------------------------------------------------------------
    ///SHARP AND FLAT IMAGE PAINTER
    ///-------------------------------------------------------------------------
    void _drawSignatureImage(int index, {required StaffStore note}) {
      /// Check if it needs to be paint.
      if (note.isOn && (note.withSharp || note.withFlat)) {
        ///Select image to paint.
        ui.Image _image() => note.withSharp ? imageSharp! : imageFlat!;
        canvas.drawImage(
          _image(),
          Offset(
            ///Sharp/Flat image will be painted left of corresponding note
            ///by [_imageLeftIndent] pixel.
            _noteXAxisPosition(index) - _imageLeftIndent,
            _noteYAxisPosition(index) -
                _signatureTopPadding(isSharp: note.withSharp),
          ),
          paintSignature,
        );
      }
    }

    ///
    ///-------------------------------------------------------------------------
    ///LOOP FOR NON-STANDARD PAINT.
    ///-------------------------------------------------------------------------
    for (int _index = 1; _index < _maxNotes(); _index++) {
      ///Draw left side line.
      _drawNonStandardStaff(_index, isLeft: true);

      ///Draw right side line.
      _drawNonStandardStaff(_index, isLeft: false);
    }

    ///
    ///-------------------------------------------------------------------------
    ///LOOP FOR MUSIC NOTE PAINT.
    ///-------------------------------------------------------------------------
    ///Need to start looping from 1 since [_index] will be use to calculate
    ///position.
    ///then find an actual index for each music note in each key(F,G) and store
    ///in [_actualIndex].
    for (int _index = 1; _index < _endIndex(); _index++) {
      ///Actual index of note in each key.
      int _actualIndex = _index - 1 + _plusIndex();

      ///Draw note.
      _drawOvalNote(_index, isOn: playing[_actualIndex].isOn);

      ///Draw left indented note if in case.
      if (playing[_actualIndex].withNatural) {
        _drawOvalNote(_index, isOn: playing[_actualIndex].isOn, onLeft: true);
      }

      ///Draw signature image.
      _drawSignatureImage(_index, note: playing[_actualIndex]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

///OLD LOGIC FOR SHARP/FLAT Y AXIS
// keySig == KeySig.g
//     ? (size.height - _lineSpace() * _index) -
//         ((size.width / _maxNotes()) / 2) +
//         (_lineSpace() *
//             _signatureTopPaddingG(
//                 playing[_index - 1 + _plusIndex()].withSharp)) -
//         _lineSpace()
//     : (size.height - _lineSpace() * _index) -
//         ((size.width / _maxNotes()) / 2) -
//         (_lineSpace() *
//             _signatureTopPaddingF(
//                 playing[_index - 1 + _plusIndex()].withSharp)) -
//         _lineSpace(),
