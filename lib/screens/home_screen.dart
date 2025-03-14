import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import 'add_post_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
    "location": "Delhi, India",
    "photoUrl": "https://images.unsplash.com/photo-1600585154340-be6161a56a0c",
    "heading": "#Sunset",
    "description": "Beautiful sunset at India Gate, Delhi.",
    "authorities": ["Admin", "Verified", "Govt"],
  },
  {
    "location": "Delhi, India",
    "photoUrl": "https://images.unsplash.com/photo-1599058917212-d6f5bf86de1c",
    "heading": "#Monuments",
    "description": "Exploring the historic Red Fort in Delhi.",
    "authorities": ["Heritage", "Tourism", "Govt"],
  },
  {
    "location": "Mumbai, India",
    "photoUrl": "https://images.unsplash.com/photo-1560347876-aeef00ee58a1",
    "heading": "#MarineDrive",
    "description": "Chilling at Marine Drive during sunset.",
    "authorities": ["Verified", "Tourism"],
  },
  {
    "location": "Mumbai, India",
    "photoUrl": "https://images.unsplash.com/photo-1576566588028-4147b0dff78e",
    "heading": "#CityLife",
    "description": "Mumbai never sleeps! Capturing the city lights.",
    "authorities": ["Admin", "CultureDept"],
  },
  {
    "location": "Bangalore, India",
    "photoUrl": "https://images.unsplash.com/photo-1580499837103-39f5406b31e3",
    "heading": "#TechCity",
    "description": "Busy streets of Bangalore, the tech hub of India.",
    "authorities": ["Admin", "Verified"],
  },
  {
    "location": "Bangalore, India",
    "photoUrl": "https://images.unsplash.com/photo-1587049352854-c6c45f24f152",
    "heading": "#Lalbagh",
    "description": "Morning walk in Lalbagh Botanical Garden, Bangalore.",
    "authorities": ["Nature", "Govt"],
  },
];

  String _selectedCity = 'Delhi, India'; // Default city for local feed

  final List<String> _cities = [
    'Delhi, India',
    'Mumbai, India',
    'Chennai, India',
    'Kolkata, India',
    'Bangalore, India'
  ];

  void _addNewPost(Map<String, dynamic> post) {
    setState(() => _posts.insert(0, post)); // Add on top
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left buttons (User Profile & Leaderboard)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.account_circle, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.leaderboard, color: Colors.black),
                    onPressed: () {
                      // TODO: Navigate to leaderboard screen
                    },
                  ),
                ],
              ),
              // Right logo
              Row(
                children: const [
                  Icon(Icons.camera, color: Colors.black),
                  SizedBox(width: 4),
                  Text('JantaGram', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: "Local Feed"),
                  Tab(text: "Nation"),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      // City Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue, size: 24),
                                const SizedBox(width: 8),
                                const Text('City: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87)),
                              ],
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCity,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Colors.black87, fontSize: 16),
                                borderRadius: BorderRadius.circular(12),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCity = newValue!;
                                  });
                                },
                                items: _cities.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Feed filtered by selected city
                      Expanded(
                        child: FeedList(
                          posts: _posts.where((post) => post['location'] == _selectedCity).toList(),
                        ),
                      ),
                    ],
                  ),
                  // Nation Feed (all posts)
                  FeedList(posts: _posts),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue[700],
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPostScreen(onPostAdded: _addNewPost),
              ),
            );
          },
          child: const Icon(Icons.add_a_photo),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Icon(Icons.home),
              ),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  // TODO: Navigate to leaderboard screen
                },
                child: const Icon(Icons.leaderboard),
              ),
              label: "Leaderboard",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Likes",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          currentIndex: 0, // Set to 0 since this is the Home screen
        ),
      ),
    );
  }
}

// Reusable Feed List Widget
class FeedList extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const FeedList({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return posts.isNotEmpty
        ? ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(
              location: posts[index]['location']!,
              photoUrl: posts[index]['photoUrl']!,
              heading: posts[index]['heading']!,
              description: posts[index]['description']!,
              authorities: List<String>.from(posts[index]['authorities']!),
            ),
          )
        : const Center(
            child: Text("No posts available for this city!", style: TextStyle(fontSize: 16)),
          );
  }
}