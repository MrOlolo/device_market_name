import 'dart:convert';
import 'dart:io';

import 'package:device_market_name/src/settings/settings.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

///IosDBProvider
///Get ios devices database from json
class IosDBProvider {
  IosDBProvider._();

  static final IosDBProvider db = IosDBProvider._();

  Map<String, String>? _database;
  Map<String, String>? _databaseWithoutNetwork;

  ///Get or init&get database
  Future<Map<String, String>> get database async {
    if (_database != null) return _database!;
    _database = await initDB(withoutNetwork: false);
    return _database!;
  }

  ///Get or init&get database without network ids
  Future<Map<String, String>> get databaseWithoutNetwork async {
    if (_databaseWithoutNetwork != null) return _databaseWithoutNetwork!;
    _databaseWithoutNetwork = await initDB();
    return _databaseWithoutNetwork!;
  }

  ///Manual init databases
  initDB({bool withoutNetwork = true}) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    late final String name;
    if (withoutNetwork) {
      name = iosWithoutNetworkDbName;
    } else {
      name = iosNetworkDbName;
    }
    String dbPath = join(documentsDirectory.path, name);
    late List<int> bytes;
    try {
      if (withoutNetwork) {
        bytes = await http.readBytes(Uri.parse(iosNamesWithoutNetworkLink));
      } else {
        bytes = await http.readBytes(Uri.parse(iosNamesLink));
      }
      await File(dbPath).writeAsBytes(bytes);
    } catch (e) {
      if (FileSystemEntity.typeSync(dbPath) == FileSystemEntityType.notFound) {
        final data =
            await rootBundle.load("packages/device_market_name/lib/db/$name");
        bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes);
      } else {
        bytes = await File(dbPath).readAsBytes();
      }
    }

    final str = String.fromCharCodes(bytes);
    return Map<String, String>.from(jsonDecode(str));
  }

  ///Get iOS device market name by modelCode with network id
  Future<String?> getMarketName(String modelCode) async {
    final db = await database;
    return db[modelCode];
  }

  ///Get iOS device market name by modelCode without network id
  Future<String?> getMarketNameWithoutNetwork(String modelCode) async {
    final db = await databaseWithoutNetwork;
    return db[modelCode];
  }
}
