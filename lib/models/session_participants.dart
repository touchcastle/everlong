import 'package:everlong/services/piano.dart';

class SessionMember {
  ///Member's device UUID
  final String id;

  ///Member's name
  final String name;

  ///Room's host(teacher)
  final bool isHost;

  ///Timestamp from clock-in function updated periodically updated from
  ///firestore. Will use to check member connection status.
  int lastSeen;

  ///Listenable is student can broadcast MIDI message back to firestore
  ///(permitted by room host(teacher)
  bool listenable;

  ///Flag for deletion
  bool isSignedOut = false;

  ///For virtual piano display when member is listenable
  Piano piano = Piano();

  SessionMember({
    required this.id,
    required this.name,
    required this.isHost,
    required this.lastSeen,
    this.listenable = false,
  });

  ///Initialize member's piano function for display.
  void initPiano() => this.piano.keyList = this.piano.generateKeysList();

  Future toggleListenable(bool toggle) async {
    this.listenable = toggle;
  }
}
