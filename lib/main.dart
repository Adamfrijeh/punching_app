import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const PunchApp());
}

class PunchApp extends StatelessWidget {
  const PunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Punch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.purple,
      ),
      home: const LoginPage(),
    );
  }
}
