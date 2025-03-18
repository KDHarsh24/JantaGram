import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; 
import '../screens/user_profile_screen.dart'; 
import '../screens/leaderboard_screen.dart'; 
import '../screens/inprogress.dart'; 
import '../screens/solved.dart';
// TODO: Import other screens if needed

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  String email;
  BottomNavBar({Key? key, required this.currentIndex, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return; // Prevent reloading the same page

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen(email: 'harshkumardas24@gmail.com')),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InProgress(email: 'harshkumardas24@gmail.com')),
            );
            break;
            case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Solved(email: 'harshkumardas24@gmail.com',)),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LeaderboardScreen(email: email,)),
            );
            break;
          

          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen(email: email)),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.construction),
          label: "In Progress",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: "Solved",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: "Leaderboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}