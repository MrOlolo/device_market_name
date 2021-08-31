import 'dart:io';

import 'package:device_market_name/src/settings/settings.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

///AndroidDBProvider
///Get Android devices database from sqlite
class AndroidDBProvider {
  AndroidDBProvider._();

  static final AndroidDBProvider db = AndroidDBProvider._();

  Database? _database;

  ///Get or init&get database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  ///Manual init database
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, androidDbName);
    late List<int> bytes;
    try {
      bytes = await http.readBytes(Uri.parse(androidNamesLink));
      await File(dbPath).writeAsBytes(bytes);
    } catch (e) {
      if (FileSystemEntity.typeSync(dbPath) == FileSystemEntityType.notFound) {
        final data = await rootBundle
            .load("packages/device_market_name/lib/db/$androidDbName");
        bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes);
      }
    }
    return await openDatabase(
      dbPath,
      readOnly: true,
    );
  }

  ///Get Android device market name by modelCode
  Future<String?> getMarketNameByModelCode(String modelCode) async {
    final db = await database;
    final res = await db.query(androidDbTable,
        columns: [androidDbMarketNameColumn],
        where: "$androidDbModelCodeColumn = ?",
        whereArgs: [modelCode]);
    return res.isNotEmpty
        ? res.first[androidDbMarketNameColumn].toString()
        : null;
  }
}
