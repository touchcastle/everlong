import 'package:everlong/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:everlong/models/record_database.dart';

class RecordDatabase {
  List<DatabaseRecord>? databaseRecord = [];

  Future<Database> _database() async => openDatabase(
        join(await getDatabasesPath(), kDbName),
      );

  Future updateRecord({required String id, required String data}) async {
    if (databaseRecord!.indexWhere((d) => d.id == id) < 0) {
      dbInsertRecord(id: id, data: data);
      databaseRecord?.add(DatabaseRecord(id: id, record: data));
    } else {
      dbUpdateRecord(id: id, data: data);
      int _i = databaseRecord!.indexWhere((d) => d.id == id);
      databaseRecord![_i].record = data;
    }
  }

  // Query Device Database
  Future<List<DatabaseRecord>> dbQueryRecord() async {
    final Database db = await _database();
    final List<Map<String, dynamic>> maps = await db.query(kDbRecord);
    return List.generate(maps.length, (i) {
      return DatabaseRecord(id: maps[i]['id'], record: maps[i]['record']);
    });
  }

  Future<void> dbInsertRecord(
      {required String id, required String data}) async {
    DatabaseRecord _insertData = DatabaseRecord(id: id, record: data);
    final Database db = await _database();
    await db.insert(
      kDbRecord, //Table name
      _insertData.toMap(), //Data's Row
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //Update Record
  Future<void> dbUpdateRecord(
      {required String id, required String data}) async {
    DatabaseRecord _updateData = DatabaseRecord(id: id, record: data);
    final db = await _database();
    await db.update(
      kDbRecord,
      _updateData.toMap(),
      where: "id = ?",
      whereArgs: [_updateData.id],
    );
  }

  //Delete Device
  Future<void> dbDeleteRecord({required String id}) async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), kDbName),
    );
    final db = await database;

    await db.delete(
      kDbRecord,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Get displayName from [databaseDeviceName] and return.
  ///
  /// If not found, return old same [name].
  // String getStoredName({required String id, required String name}) {
  //   String _deviceName = name;
  //   if (databaseDeviceName != null) {
  //     int _i = databaseDeviceName!.indexWhere((d) => d.id == id);
  //     if (_i >= 0) {
  //       _deviceName = databaseDeviceName![_i].deviceName;
  //     }
  //   }
  //   return _deviceName;
  // }
}
