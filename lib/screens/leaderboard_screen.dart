import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Selected time period filter
  String _selectedPeriod = "all_time";

  // Track if data is loading
  bool _isLoading = false;

  // Mock leaderboard data for different time periods
  final Map<String, List<Map<String, dynamic>>> _leaderboardData = {
    "all_time": [
      {"name": "Chirag Goyal", "points": 1500, "profilePic": "https://via.placeholder.com/150", "badge": "Super Contributor", "id": "user1"},
      {"name": "Aditi Sharma", "points": 1400, "profilePic": "https://via.placeholder.com/150", "badge": "Active Member", "id": "user2"},
      {"name": "Rahul Verma", "points": 1300, "profilePic": "https://via.placeholder.com/150", "badge": "Rising Star", "id": "user3"},
      {"name": "Neha Singh", "points": 1200, "profilePic": "https://via.placeholder.com/150", "badge": "Verified Local", "id": "user4"},
      {"name": "Karan Patel", "points": 1100, "profilePic": "https://via.placeholder.com/150", "badge": "Top Reporter", "id": "user5"},
      {"name": "Sanya Mehta", "points": 1000, "profilePic": "https://via.placeholder.com/150", "badge": "Consistent", "id": "user6"},
      {"name": "Rohan Das", "points": 900, "profilePic": "https://via.placeholder.com/150", "badge": "Helpful", "id": "user7"},
      {"name": "Meera Kapoor", "points": 850, "profilePic": "https://via.placeholder.com/150", "badge": "New Member", "id": "user8"},
    ],
    "this_month": [
      {"name": "Aditi Sharma", "points": 742, "profilePic": "https://via.placeholder.com/150", "badge": "Active Member", "id": "user2"},
      {"name": "Chirag Goyal", "points": 725, "profilePic": "https://via.placeholder.com/150", "badge": "Super Contributor", "id": "user1"},
      {"name": "Neha Singh", "points": 682, "profilePic": "https://via.placeholder.com/150", "badge": "Verified Local", "id": "user4"},
      {"name": "Rahul Verma", "points": 610, "profilePic": "https://via.placeholder.com/150", "badge": "Rising Star", "id": "user3"},
      {"name": "Rohan Das", "points": 585, "profilePic": "https://via.placeholder.com/150", "badge": "Helpful", "id": "user7"},
      {"name": "Karan Patel", "points": 520, "profilePic": "https://via.placeholder.com/150", "badge": "Top Reporter", "id": "user5"},
      {"name": "Sanya Mehta", "points": 465, "profilePic": "https://via.placeholder.com/150", "badge": "Consistent", "id": "user6"},
      {"name": "Meera Kapoor", "points": 410, "profilePic": "https://via.placeholder.com/150", "badge": "New Member", "id": "user8"},
    ],
    "this_week": [
      {"name": "Rahul Verma", "points": 320, "profilePic": "https://via.placeholder.com/150", "badge": "Rising Star", "id": "user3"},
      {"name": "Neha Singh", "points": 280, "profilePic": "https://via.placeholder.com/150", "badge": "Verified Local", "id": "user4"},
      {"name": "Aditi Sharma", "points": 260, "profilePic": "https://via.placeholder.com/150", "badge": "Active Member", "id": "user2"},
      {"name": "Chirag Goyal", "points": 230, "profilePic": "https://via.placeholder.com/150", "badge": "Super Contributor", "id": "user1"},
      {"name": "Meera Kapoor", "points": 195, "profilePic": "https://via.placeholder.com/150", "badge": "New Member", "id": "user8"},
      {"name": "Rohan Das", "points": 180, "profilePic": "https://via.placeholder.com/150", "badge": "Helpful", "id": "user7"},
      {"name": "Karan Patel", "points": 165, "profilePic": "https://via.placeholder.com/150", "badge": "Top Reporter", "id": "user5"},
      {"name": "Sanya Mehta", "points": 130, "profilePic": "https://via.placeholder.com/150", "badge": "Consistent", "id": "user6"},
    ],
  };

  // Fetch leaderboard data
  Future<void> _fetchLeaderboardData(String period) async {
    // In a real app, this would be an API call
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // This is where you would make the actual API call
    // Example:
    // final response = await http.get(Uri.parse('$apiBaseUrl/leaderboard?period=$period'));
    // final data = jsonDecode(response.body);
    
    setState(() {
      _selectedPeriod = period;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current leaderboard data based on selected period
    final currentData = _leaderboardData[_selectedPeriod]!;
    
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
            onPressed: () => _fetchLeaderboardData(_selectedPeriod),
          ),
        ],
      ),
      body: _isLoading
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
                    child: Row(
                      children: [
                        _buildPeriodTab("All Time", "all_time"),
                        _buildPeriodTab("This Month", "this_month"),
                        _buildPeriodTab("This Week", "this_week"),
                      ],
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // Build period tab button
  Widget _buildPeriodTab(String label, String periodValue) {
    final isSelected = _selectedPeriod == periodValue;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _fetchLeaderboardData(periodValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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