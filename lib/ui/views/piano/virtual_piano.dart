import 'package:flutter/material.dart';
import 'package:everlong/services/piano.dart';

enum KeyColor { WHITE, BLACK }

class VirtualPiano extends StatefulWidget {
  final double height;
  final Piano piano;
  VirtualPiano(this.piano, {this.height = 60});
  @override
  _VirtualPianoState createState() => new _VirtualPianoState();
}

class _VirtualPianoState extends State<VirtualPiano> {
  @override
  Widget build(BuildContext ct) {
    return Container(
      height: widget.height,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final whiteKeySize = constraints.maxWidth / (21);
          final blackKeySize = whiteKeySize / 1.7;

          List<Widget> _keysInOctave() {
            List<Widget> _list = [];
            for (int _octave = 3; _octave <= 5; _octave++) {
              _list.add(Stack(
                children: [
                  _buildWhiteKeys(widget.piano, whiteKeySize, octave: _octave),
                  _buildBlackKeys(widget.piano, constraints.maxHeight,
                      blackKeySize, whiteKeySize,
                      octave: _octave),
                ],
              ));
            }
            return _list;
          }

          return Row(children: _keysInOctave());
        },
      ),
    );
  }

  _buildWhiteKeys(Piano piano, double whiteKeySize, {required int octave}) {
    return Row(
      children: [
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 3].isPressing,
        ),
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 5].isPressing,
        ),
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 7].isPressing,
        ),
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 8].isPressing,
        ),
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 10].isPressing,
        ),
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 12].isPressing,
        ),
        PianoKey.white(
          width: whiteKeySize,
          isPressing: piano.keyList[(12 * (octave - 1)) + 14].isPressing,
        )
      ],
    );
  }

  _buildBlackKeys(
      Piano piano, double pianoHeight, double blackKeySize, double whiteKeySize,
      {required int octave}) {
    return Container(
      height: pianoHeight * 0.6,
      child: Row(
        children: [
          SizedBox(
            width: whiteKeySize - blackKeySize / 2,
          ),
          PianoKey.black(
            width: blackKeySize,
            isPressing: piano.keyList[(12 * (octave - 1)) + 4].isPressing,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            isPressing: piano.keyList[(12 * (octave - 1)) + 6].isPressing,
          ),
          SizedBox(
            width: whiteKeySize,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            isPressing: piano.keyList[(12 * (octave - 1)) + 9].isPressing,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            isPressing: piano.keyList[(12 * (octave - 1)) + 11].isPressing,
          ),
          SizedBox(
            width: whiteKeySize - blackKeySize,
          ),
          PianoKey.black(
            width: blackKeySize,
            isPressing: piano.keyList[(12 * (octave - 1)) + 13].isPressing,
          ),
        ],
      ),
    );
  }
}

class PianoKey extends StatelessWidget {
  final KeyColor color;
  final double width;
  final bool isPressing;

  const PianoKey.white({
    required this.width,
    this.isPressing = false,
  }) : this.color = KeyColor.WHITE;

  const PianoKey.black({
    required this.width,
    this.isPressing = false,
  }) : this.color = KeyColor.BLACK;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isPressing
            ? Colors.red
            : color == KeyColor.WHITE
                ? Colors.white
                : Colors.black,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
      ),
    );
  }
}
