class DatabaseDeviceName {
  final String? id;
  String deviceName;

  DatabaseDeviceName({this.id, required this.deviceName});

  //For database mapping.
  Map<String, dynamic> toMap() => {'id': id, 'deviceName': deviceName};
}
