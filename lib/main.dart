import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/user_profile_screen.dart'; // Import User Profile Page
import './screens/registerpage.dart';
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
      debugShowCheckedModeBanner: false,

      // ✅ Define Routes
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(email: 'harshkumardas24@gmail.com',),
        '/profile': (context) => UserProfileScreen(),
        '/login': (context) => RegisterPage(email: 'harshkumardas24@gmail.com'),
      },
    );
  }
}