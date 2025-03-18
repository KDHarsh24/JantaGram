import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; 
import '../screens/user_profile_screen.dart'; 
import '../screens/leaderboard_screen.dart'; 
// import '../screens/in_progress_screen.dart'; 
// import '../screens/solved_screen.dart';
// TODO: Import other screens if needed

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

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
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const InProgressScreen()),
            // );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
            );
            break;
          case 3:
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const SolvedScreen()),
            // );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen()),
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
          icon: Icon(Icons.leaderboard),
          label: "Leaderboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: "Solved",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
