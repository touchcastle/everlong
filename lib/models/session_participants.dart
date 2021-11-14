import 'package:everlong/services/piano.dart';

class SessionMember {
  final String id;
  final String name;
  final bool isHost;
  int lastSeen;
  bool listenable;
  bool isSignedOut = false;
  Piano piano = Piano();

  SessionMember({
    required this.id,
    required this.name,
    required this.isHost,
    required this.lastSeen,
    this.listenable = false,
  });

  Future toggleListenable(bool toggle) async {
    this.listenable = toggle;
  }

  void initPiano() => this.piano.keyList = this.piano.generateKeysList();
}
