import 'package:appeducafin/views/login.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(
    DevicePreview(
      enabled: true, // Habilita o DevicePreview
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
      home:LoginScreen(),
    );
  }
}