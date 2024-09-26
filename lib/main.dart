import 'package:flutter/material.dart';
import 'package:weather_app/home.dart';

void main() {
  runApp(const MainClass());
}

class MainClass extends StatelessWidget {
  const MainClass({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeClass(),
    );
  }
}
