import 'package:flutter/material.dart';

void main() {
  runApp(const BreathLabApp());
}

class BreathLabApp extends StatelessWidget {
  const BreathLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'BreathLab', home: Scaffold());
  }
}
