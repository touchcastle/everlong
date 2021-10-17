class SessionMember {
  final String id;
  final String name;
  final bool isHost;
  int lastSeen;

  SessionMember({
    required this.id,
    required this.name,
    required this.isHost,
    required this.lastSeen,
  });
}
