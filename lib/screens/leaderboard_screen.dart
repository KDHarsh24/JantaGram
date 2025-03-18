import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/bottom_navbar.dart';
import '../config.dart';

class LeaderboardScreen extends StatefulWidget {
  String email;
  LeaderboardScreen({super.key, required this.email});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {

  // Track if data is loading
  bool isLoading = false;

  // Mock leaderboard data for different time periods
  List<Map<String, dynamic>> _leaderboardData = [
    ];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard(); // Fetch data on screen load
  }
  // Fetch leaderboard data
  Future<void> _fetchLeaderboard() async {
    try {
      final String url = '${Config.baseUrl}/user/leaderboard'; // ✅ Backend API URL

      final response = await http.post(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timed out"),
      );

      if (response.statusCode == 201) {
        List<dynamic> responseData = json.decode(response.body)['data'];
        print(responseData);
        setState(() {
          _leaderboardData = responseData.map<Map<String, dynamic>>((item) {
            return {
              "name": item["name"],
              "points": item["points"],
              "profilePic": "https://th.bing.com/th/id/OIP.Z8d1mi6B_6j2JbElEPl-QQHaHa?rs=1&pid=ImgDetMain", // ✅ Placeholder image
              "badge": "", // ✅ Default badge (optional, can be empty)
              "id": item["_id"] ?? "",
            };
          }).toList();

          isLoading = false; // ✅ Stop loading
        });
      } else {
        throw Exception("Failed to fetch leaderboard");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }


    // This is where you would make the actual API call
    // Example:
    // final response = await http.get(Uri.parse('$apiBaseUrl/leaderboard?period=$period'));
    // final data = jsonDecode(response.body);
    

  @override
  Widget build(BuildContext context) {
    // Get the current leaderboard data based on selected period
    final currentData = _leaderboardData;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Leaderboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info about points system
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Points System"),
                  content: const Text(
                      "Points are earned through community contributions:\n\n• Creating posts: 10 points\n• Verified reports: 20 points\n• Likes received: 5 points\n• Comments: 2 points"),
                  actions: [
                    TextButton(
                      child: const Text("GOT IT"),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchLeaderboard(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top section with gradient background
                Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[700]!, Colors.blue[400]!],
                    ),
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
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Top Contributors",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Top 3 Users
                      _buildTopThree(currentData),
                    ],
                  ),
                ),
                
                // Tabs for different leaderboard categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                
                // List of Other Users
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: currentData.length > 3
                        ? ListView.builder(
                            itemCount: currentData.length - 3,
                            itemBuilder: (context, index) {
                              final user = currentData[index + 3];
                              final rank = index + 4; // Start from rank 4
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      // Rank
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "$rank",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // User Avatar
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(user["profilePic"]),
                                      ),
                                      const SizedBox(width: 12),
                                      // User Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user["name"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user["badge"],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Points
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "${user["points"]} pts",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "No more users for this period",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2, email: widget.email),
    );
  }


  // Widget to show Top 3 Users with Trophies 🏆
  Widget _buildTopThree(List<Map<String, dynamic>> data) {
    // Ensure we have at least 3 users
    if (data.length < 3) {
      return const Center(
        child: Text(
          "Not enough data to display top 3",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopUser(data[1], "🥈", 2, Colors.grey[300]!), // 2nd Place
          _buildTopUser(data[0], "🥇", 1, Colors.amber[100]!), // 1st Place
          _buildTopUser(data[2], "🥉", 3, Colors.brown[100]!), // 3rd Place
        ],
      ),
    );
  }

  // Widget to display top-ranked users
  Widget _buildTopUser(Map<String, dynamic> user, String trophy, int rank, Color podiumColor) {
    final double avatarSize = rank == 1 ? 100.0 : 80.0;
    final double podiumHeight = rank == 1 ? 100.0 : (rank == 2 ? 80.0 : 60.0);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundImage: NetworkImage(user["profilePic"]),
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(trophy, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              Text(
                "${user["points"]}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user["name"].split(" ")[0], // First name only
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 80,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              "$rank",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
        ),
      ],
    );
  }
}