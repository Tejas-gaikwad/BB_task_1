import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'connect_page.dart';

void main() async {
  runApp(const MyApp());
  // await FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ConnectPage(),
      // FlutterBlueApp(),
    );
  }
}
