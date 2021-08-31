library device_market_name;

import 'package:device_market_name/src/database/android_db_provider.dart';
import 'package:device_market_name/src/database/ios_db_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// DeviceMarketName
class DeviceMarketName {
  ///
  ///Get device market name by model code
  ///You can set [platform] to get data for another platform
  ///Works at iOS&Android
  ///
  Future<String?> getMarketName(
    String modelCode, {

    ///Support [TargetPlatform.android] & [TargetPlatform.iOS]
    TargetPlatform? platform,

    ///Return market name without network id(CDMA, LTE, GSM and etc)
    ///Work only for iOS
    bool withoutNetwork = false,
  }) async {
    if (platform == null) {
      platform = defaultTargetPlatform;
    }

    if (platform == TargetPlatform.android) {
      return await AndroidDBProvider.db.getMarketNameByModelCode(modelCode);
    } else if (platform == TargetPlatform.iOS) {
      if (withoutNetwork) {
        return await IosDBProvider.db.getMarketNameWithoutNetwork(modelCode);
      } else {
        return await IosDBProvider.db.getMarketName(modelCode);
      }
    }
    throw Exception('Support modelCode only at Android&iOS. '
        'Use [platform] to set platform manually');
  }
}
