import 'package:everlong/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Future openDB() async {
    openDatabase(join(await getDatabasesPath(), kDbName),
        onCreate: onCreateTable, onUpgrade: onUpdateTable, version: 2);
  }

  static Future onCreateTable(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $kDbDeviceName(id TEXT PRIMARY KEY NOT NULL, deviceName TEXT NOT NULL)");
    await db.execute(
        "CREATE TABLE $kDbRecord(id TEXT PRIMARY KEY NOT NULL, record TEXT NOT NULL)");
  }

  static Future onUpdateTable(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion && newVersion == 2) {
      await db.execute(
          "CREATE TABLE $kDbRecord(id TEXT PRIMARY KEY NOT NULL, record TEXT NOT NULL)");
    }
  }
}
