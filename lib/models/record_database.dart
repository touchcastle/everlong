class DatabaseRecord {
  final String id;
  String record;

  DatabaseRecord({required this.id, required this.record});

  //For database mapping.
  Map<String, dynamic> toMap() => {'id': id, 'record': record};
}
