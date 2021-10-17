class StaffStore {
  final int note;
  bool isOn;
  bool withSharp;
  bool withFlat;
  bool withNatural;
  int outOfStaff;

  StaffStore({
    required this.note,
    this.isOn = false,
    this.withSharp = false,
    this.withFlat = false,
    this.withNatural = false,
    this.outOfStaff = 0,
  });
}
