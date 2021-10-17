import 'package:everlong/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Future openDB() async {
    openDatabase(join(await getDatabasesPath(), kDbName),
        onCreate: onCreateTable, onUpgrade: onUpdateTable, version: 1);
  }

  static Future onCreateTable(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $kDbDeviceName(id TEXT PRIMARY KEY NOT NULL, deviceName TEXT NOT NULL)");
  }

  static Future onUpdateTable(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      //1.0.0 No update yet.
    }
  }
}
