import 'package:flutter/material.dart';
import 'contacts_list_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý danh bạ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ContactsListScreen(),
    );
  }
}
