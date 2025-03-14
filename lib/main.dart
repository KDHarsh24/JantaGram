import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const JantaGram());
}

class JantaGram extends StatelessWidget {
  const JantaGram({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JantaGram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
