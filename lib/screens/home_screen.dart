import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import 'add_post_screen.dart';
import 'user_profile_screen.dart';
import 'leaderboard_screen.dart'; 
import '../widgets/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showElevation = false;

  // Sample posts data converted to PostCardModel format
  final List<PostCardModel> _posts = [
    PostCardModel(
      id: '1',
      location: "Delhi, India",
      photoUrl: "https://media.istockphoto.com/id/865297750/photo/litter-on-the-street.jpg?s=612x612&w=0&k=20&c=fSWi30g42yaiBYIVP9bAQi9hme6E4Cy79bc7EIvaBSA=",
      heading: "#DirtyStreet",
      description: "Dirty street at India Gate, Delhi.",
      authorities: ["Admin", "Verified", "Govt"],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      initialLikeCount: 124,
    ),
    PostCardModel(
      id: '2',
      location: "Mumbai, India",
      photoUrl: "https://images.unsplash.com/photo-1560347876-aeef00ee58a1",
      heading: "#MarineDrive",
      description: "Chilling at Marine Drive during sunset.",
      authorities: ["Verified", "Tourism"],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      initialLikeCount: 89,
    ),
    PostCardModel(
      id: '3',
      location: "Delhi, India",
      photoUrl: "https://media.istockphoto.com/id/929942316/photo/old-highway-with-holes-and-snow-landscape-road-potholes-in-cloudy-winter-weather-concept.jpg?s=612x612&w=0&k=20&c=ZtK8wJgXLQYEWGMJVGeyZBqVPKsdHMQlml1Vx8i17aw=",
      heading: "#DelhiRoads",
      description: "Very Bad condition of Roads.",
      authorities: ["Municipal", "Pwd"],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      initialLikeCount: 152,
    ),
  ];

  String _selectedCity = 'Delhi, India'; // Default city for local feed

  final List<String> _cities = [
    'Delhi, India',
    'Mumbai, India',
    'Chennai, India',
    'Kolkata, India',
    'Bangalore, India'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen to scroll events to show/hide elevation
    _scrollController.addListener(() {
      setState(() {
        _showElevation = _scrollController.offset > 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewPost(PostCardModel post) {
    setState(() => _posts.insert(0, post)); // Add on top
  }

  void _handleLikeToggled(String postId, bool isLiked) {
    // This would typically be an API call in a real app
    debugPrint('Post $postId like toggled to $isLiked');
    // You could update a backend or perform additional actions here
  }

  void _handleShare(String postId) {
    // Implement share functionality
    debugPrint('Sharing post $postId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing post $postId'))
    );
  }

  void _handleAuthorityTap(String authority) {
    debugPrint('Authority tapped: $authority');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing $authority posts'))
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: _showElevation ? 2 : 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left buttons (User Profile & Leaderboard)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.black87, size: 26),
                      splashRadius: 24,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserProfileScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.leaderboard, color: Colors.black87, size: 24),
                      splashRadius: 24,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                        );
                      },
                    ),
                  ],
                ),
                // Right logo
                Row(
                  children: [
                    Icon(Icons.camera_alt, color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      'JantaGram', 
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Local Feed"),
              Tab(text: "Nation"),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Local Feed Tab
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // City Selector
                SliverToBoxAdapter(
                  child: _buildCitySelector(),
                ),
                // Feed filtered by selected city
                _buildFeedList(
                  _posts.where((post) => post.location == _selectedCity).toList()
                ),
              ],
            ),
            
            // Nation Feed Tab (all posts)
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildFeedList(_posts),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPostScreen(
                  onPostAdded: (Map<String, dynamic> postData) {
                    _addNewPost(PostCardModel.fromJson(postData));
                  },
                ),
              ),
            );
          },
          elevation: 4,
          child: const Icon(Icons.add_a_photo),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildCitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Local Updates: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87
                )
              ),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
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
    );
  }

  Widget _buildFeedList(List<PostCardModel> posts) {
    return posts.isNotEmpty
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => PostCard(
                post: posts[index],
                onLikeToggled: _handleLikeToggled,
                onShare: _handleShare,
                onAuthorityTap: _handleAuthorityTap,
                onTap: (postId) {
                  // Navigate to post detail screen if needed
                  debugPrint('Post $postId tapped');
                },
              ),
              childCount: posts.length,
            ),
          )
        : SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.post_add,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No posts available for this city!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Be the first to post an update!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

// You'll need to update this class as well to work with PostCardModel