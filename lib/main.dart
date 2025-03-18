import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/user_profile_screen.dart'; // Import User Profile Page
import './screens/registerpage.dart';
import './screens/loginpage.dart';
import './screens/inprogress.dart';
import './screens/solved.dart';

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
        '/': (context) => const HomeScreen(email: ''),
        '/hdept': (context) => const HomeScreen(email: ''),
        '/inprog':
            (context) => const InProgress(email: ''),
        '/solved':
            (context) => const Solved(email: ''),
        '/profile':
            (context) => UserProfileScreen(email: ''),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
