import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'views/login.dart';


void main() {
  runApp(
    DevicePreview(
      enabled: true, // Habilita o DevicePreview
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: DevicePreview.appBuilder,
      home:LoginScreen(),
    );
  }
}