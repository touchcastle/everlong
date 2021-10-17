import 'package:flutter/material.dart';
import 'package:everlong/ui/views/screens/screen.dart';
import 'package:everlong/utils/colors.dart';

///5 Lines of music staff.
Container staffsPainter(
  BuildContext context, {
  required KeySig keySig,
  required double width,
  required double height,
}) {
  return Container(
    color: kStaffArea,
    width: width,
    height: height,
    child: CustomPaint(
        foregroundPainter: LinePainter(keySig: keySig),
        size: MediaQuery.of(context).size),
  );
}

///Painter of 5 Lines of music staff
///
///This class will be called twice since there are 2 keys (G and F) which
///has different logic and position.
class LinePainter extends CustomPainter {
  final KeySig keySig;
  LinePainter({required this.keySig});

  ///Maximum display line of notes for each key.
  int _maxNotes() => keySig == KeySig.g ? 30 : 24;

  ///Index to start painting the line.
  int _startLine() => keySig == KeySig.g ? 19 : 2;

  ///Index to stop painting the line.
  int _endLine() => keySig == KeySig.g ? 27 : 10;

  @override
  void paint(Canvas canvas, Size size) {
    final paintNull = Paint()..color = Colors.transparent;

    ///Paint staff line.
    final paintLine = Paint()
      ..color = kStaffColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    ///Paint bold black vertical line at most left of the staff.
    final paintLineVertical = Paint()
      ..color = Colors.black
      // ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    ///Space between each note's line. (1 staff line has 2 note line)
    ///*has same calculation in view/screens/notes.dart
    double _lineSpace() => size.height / 30;

    ///Calculate position in Y axis for each index of non-standard staff.
    ///*has same calculation in view/screens/notes.dart
    double _staffYAxisPosition(int index) => this.keySig == KeySig.g
        ? _lineSpace() * index
        : _lineSpace() * index - _lineSpace();

    ///PAINTER
    ///Standard 5 lines painter.
    for (int _index = 1; _index < _maxNotes(); _index++) {
      canvas.drawLine(
        ///Left start point of line.
        Offset(1, _staffYAxisPosition(_index)),

        ///Right end point of line.
        Offset(size.width, _staffYAxisPosition(_index)),

        ///Only paint when it is a correct Y axis position on canvas
        keySig == KeySig.g
            ? _index.isOdd && (_index >= _startLine() && _index <= _endLine())
                ? paintLine
                : paintNull
            : _index.isEven && (_index >= _startLine() && _index <= _endLine())
                ? paintLine
                : paintNull,
      );
    }

    ///Bold black vertical line painter.
    canvas.drawLine(
      Offset(1, keySig == KeySig.g ? _lineSpace() * 19 : 0),
      Offset(1, keySig == KeySig.g ? size.height : _lineSpace() * 9),
      paintLineVertical,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
