import 'package:everlong/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:everlong/models/device_database.dart';

class DeviceDatabase {
  List<DatabaseDeviceName>? databaseDeviceName = [];

  Future<Database> _database() async => openDatabase(
        join(await getDatabasesPath(), kDbName),
      );

  Future updateName({required String id, required String name}) async {
    if (databaseDeviceName!.indexWhere((d) => d.id == id) < 0) {
      dbInsertDevice(id: id, name: name);
      databaseDeviceName?.add(DatabaseDeviceName(id: id, deviceName: name));
    } else {
      dbUpdateDevice(id: id, name: name);
      int _i = databaseDeviceName!.indexWhere((d) => d.id == id);
      databaseDeviceName![_i].deviceName = name;
    }
  }

  //Query Device Database
  Future<List<DatabaseDeviceName>> dbQueryDevice() async {
    final Database db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(kDbDeviceName);
    return List.generate(maps.length, (i) {
      return DatabaseDeviceName(
          id: maps[i]['id'], deviceName: maps[i]['deviceName']);
    });
  }

  Future<void> dbInsertDevice(
      {required String id, required String name}) async {
    DatabaseDeviceName _insertData =
        DatabaseDeviceName(id: id, deviceName: name);
    final Database db = await _database();
    await db.insert(
      kDbDeviceName, //Table name
      _insertData.toMap(), //Data's Row
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Update Device
  Future<void> dbUpdateDevice(
      {required String id, required String name}) async {
    DatabaseDeviceName _updateData =
        DatabaseDeviceName(id: id, deviceName: name);
    final db = await _database();
    await db.update(
      kDbDeviceName,
      _updateData.toMap(),
      where: "id = ?",
      whereArgs: [_updateData.id],
    );
  }

  //Delete Device
  Future<void> dbDeleteDevice({required String id}) async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), kDbName),
    );
    final db = await database;

    await db.delete(
      kDbDeviceName,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Get displayName from [databaseDeviceName] and return.
  ///
  /// If not found, return old same [name].
  String getStoredName({required String id, required String name}) {
    int _nameIndex = -1;
    String _deviceName = name;
    if (databaseDeviceName != null) {
      _nameIndex =
          databaseDeviceName!.indexWhere((element) => element.id == id);
      if (_nameIndex >= 0) {
        _deviceName = databaseDeviceName![_nameIndex].deviceName;
      }
    }
    return _deviceName;
  }
}
