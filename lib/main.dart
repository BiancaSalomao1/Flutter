import 'package:appeducafin/firebase_options.dart';
import 'package:appeducafin/views/home.dart';
import 'package:appeducafin/views/login.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';





void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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