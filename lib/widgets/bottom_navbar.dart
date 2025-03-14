import 'package:flutter/material.dart';
import '../screens/home_screen.dart'; 
import '../screens/user_profile_screen.dart'; 
//import '../screens/leaderboard_screen.dart'; 
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
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            break;
          case 1:
            // TODO: Navigate to Search Screen
            break;
          case 2:
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
            // );
            break;
          case 3:
            // TODO: Navigate to Likes Screen
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
          icon: Icon(Icons.search),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: "Leaderboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Likes",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
