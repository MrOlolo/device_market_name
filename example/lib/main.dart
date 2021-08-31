import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_market_name/device_market_name.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeviceMarketName',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'DeviceMarketName'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? marketName;
  String? modelCode;

  @override
  void initState() {
    asyncInit();
    super.initState();
  }

  asyncInit() async {
    ///E.g. Get marketName for another platform & device
    print(await DeviceMarketName()
        .getMarketName('iPhone13,2', platform: TargetPlatform.iOS));

    ///
    ///E.g. Get marketName for current device
    ///To get device modelCode use fo e.g:
    ///[device_info_plus] - https://pub.dev/packages/device_info_plus
    ///
    try {
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        modelCode = deviceInfo.model;
      } else if (Platform.isIOS) {
        final deviceInfo = await DeviceInfoPlugin().iosInfo;
        modelCode = deviceInfo.utsname.machine;
      }
    } catch (_) {
      modelCode = 'unknown';
    }
    if (mounted) setState(() {});

    try {
      marketName = await DeviceMarketName().getMarketName(modelCode!);
      ///
      /// [withoutNetwork] work only at iOS devices
      /// marketName = await DeviceMarketName()
      ///     .getMarketName(modelCode!, withoutNetwork: true);
      ///
    } catch (_) {
      marketName = 'unknown';
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ModelCode: $modelCode',
            ),
            Text(
              'MarketName: $marketName',
            ),
          ],
        ),
      ),
    );
  }
}
