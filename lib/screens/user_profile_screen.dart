import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart'; // ✅ Import BottomNavBar

class UserProfileScreen extends StatelessWidget {
  String email;
  UserProfileScreen({super.key, required this.email});

  // Mock User Data
  final String userName = "Chirag Goyal";
  final String userEmail = "chirag@example.com";
  final String profilePic = "https://via.placeholder.com/150";
  final String userBio = "Flutter Developer | UI/UX Enthusiast | Tech Blogger";

  // Mock User Stats
  final int followers = 1254;
  final int following = 568;
  final int posts = 42;

  // Mock User Posts
  final List<Map<String, dynamic>> userPosts = [
    {
      "content": "Had a great day exploring Flutter!",
      "likes": 24,
      "comments": 5,
      "timeAgo": "2h ago"
    },
    {
      "content": "Excited about my new project 🚀",
      "likes": 56,
      "comments": 12,
      "timeAgo": "1d ago"
    },
    {
      "content": "Just posted a new blog on tech trends!",
      "likes": 89,
      "comments": 15,
      "timeAgo": "3d ago"
    },
    {
      "content": "Flutter makes UI development so smooth! ❤️",
      "likes": 112,
      "comments": 24,
      "timeAgo": "5d ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(profilePic),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // User Name and Email
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[100],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // User Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      userBio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[50],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatColumn("Posts", posts),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.blue[300],
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      _buildStatColumn("Followers", followers),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.blue[300],
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      _buildStatColumn("Following", following),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Posts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Posts",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List of User Posts
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      final post = userPosts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post["content"],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.favorite, color: Colors.red[400], size: 20),
                                      const SizedBox(width: 5),
                                      Text("${post["likes"]}"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.comment, color: Colors.blue[400], size: 20),
                                      const SizedBox(width: 5),
                                      Text("${post["comments"]}"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.share, color: Colors.green[400], size: 20),
                                      const SizedBox(width: 5),
                                      const Text("Share"),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 4, email: email), // ✅ Use BottomNavBar
    );
  }

  // Helper method to build stat column
  Widget _buildStatColumn(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue[100],
          ),
        ),
      ],
    );
  }
}