import 'package:flutter/material.dart';
import 'sms_analyzer_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMS Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SmsAnalyzerScreen(),
    );
  }
}
