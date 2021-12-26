enum Note { C, D, E, F, G, A, B }
enum Signature { natural, sharp, flat }

extension ParseToString on Note {
  String toShortString() => this.toString().split('.').last;
}

class PianoModel {
  final int index;
  final int virtualKey;
  final int octave;
  final Note note;
  final Signature signature;
  bool isPressing = false;

  PianoModel({
    required this.index,
    required this.virtualKey,
    required this.octave,
    required this.note,
    required this.signature,
  });
}

class LightMonitor {
  final int key;
  bool isOn;

  LightMonitor({required this.key, this.isOn = false});
}
