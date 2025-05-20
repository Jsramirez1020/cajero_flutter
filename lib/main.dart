import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(BasicATMApp());
}

class BasicATMApp extends StatelessWidget {
  const BasicATMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cajero Automático',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 18),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
