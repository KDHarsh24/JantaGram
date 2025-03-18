import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../widgets/post_card.dart';
import 'add_post_screen.dart';
import 'user_profile_screen.dart';
import 'leaderboard_screen.dart'; 
import '../widgets/bottom_navbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class Solved extends StatefulWidget {
  final String email;
  
  const Solved({Key ? key, required this.email}): super(key: key);

  @override
  State<Solved> createState() => _SolvedState();
}

class _SolvedState extends State<Solved> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final bool _showElevation = false;
  // Sample posts data converted to PostCardModel format
  List<PostCardModel> _posts = [];
  String _selectedCity = 'Chennai'; // Default city for local feed
  List<String> _cities = [];
  bool isLoading = false;
  late Map<String, dynamic> postFetchfeed = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //Calling A.P.I from
    loadFromJsonCities('assets/cities.json').then((posts) {
      setState(() {
        _cities = posts;
      });
      });
    loadFromJson('assets/posts.json').then((posts) {
      setState(() {
        _posts = posts;
      });
    });
    _fetchFeed();
    //Listen to scroll events to show/hide elevation
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _fetchFeed() async {
  try {
    setState(() {
      isLoading = true;
    });

    final String url = '${Config.baseUrl}/post/feed';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: json.encode({"email": widget.email}),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Request timed out');
      },
    );

    // Log response
    //print(response.body);
    if (response.body.isEmpty) {
      throw Exception('Empty response received from server');
    }

    final Map<String, dynamic> responseData = json.decode(response.body);


    if (responseData['data'] == null || responseData['data'] is! List) {
      setState(() {
        isLoading = false;
        _posts = [];
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No student data available'),
          backgroundColor: Colors.orange,
        )
      );
      return;
    }

    // ✅ Convert JSON array to List<PostCardModel>
    List<PostCardModel> fetchedPosts = (responseData['data'] as List)
        .map((item) => PostCardModel.fromJson(item))
        .toList();

    setState(() {
      _posts = fetchedPosts;
      isLoading = false;
    });

    await Future.delayed(const Duration(seconds: 1));
  } catch (e) {
    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      )
    );
  }
}

  Future<List<PostCardModel>> loadFromJson(String fileName) async {
    try {
      // Load the JSON file
      String jsonString = await rootBundle.loadString(fileName);
      // Decode the JSON
      List<dynamic> jsonList = json.decode(jsonString);

      List<PostCardModel> posts = jsonList.map((json) => PostCardModel.fromJson(json)).toList();

      return posts;
    } catch (e) {
      return [];
    }
  }
  Future<List<String>> loadFromJsonCities(String fileName) async {
    try {
      // Load the JSON file
      String jsonString = await rootBundle.loadString('assets/cities.json');

      // Decode and cast to List<String>
      List<dynamic> jsonList = json.decode(jsonString);
      List<String> cities = jsonList.cast<String>();

      return cities;
    } catch (e) {
      return [];
    }
  }
  //Use adding post A.P.I. here with backend
  void _addNewPost(PostCardModel post) {
    setState(() => _posts.insert(0, post));
    setState(() {
      if (!_cities.contains(post.city)) {
        _cities.add(post.city);
      }
    });
  }
  //Use upvote A.P.I. here with backend
  Future<void> _handleUpvote(String postId, bool isLiked) async{
    // This would typically be an API call in a real app
    final String url = '${Config.baseUrl}/likePost';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": widget.email, "post_Id": postId}),
      );

      if (response.statusCode == 201) {
        print('OK');
      } else {
        setState(() {
          print('Fail');
        });
      }
    } catch (e) {
      setState(() {
        print('Bye');
      });
    }
    }
    // You could update a backend or perform additional actions here

  void _handleShare(PostCardModel post) {
    final String contentToShare = '''
      📢 ${post.heading}

      📍 Location: ${post.location}
      📝 Description: ${post.description}

      🚨 Authorities Involved: ${post.authorities.join(', ')}
      ❤️ Likes: ${post.initialLikeCount}
      ''';

    Share.share(contentToShare, subject: 'Check out this issue reported on ${post.location}!');

    // Optional feedback on UI (snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing post...')),
    );
  }
  
  void _handleTagClick(String authority) {
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
                        MaterialPageRoute(builder: (context) => UserProfileScreen(email: widget.email,)),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.leaderboard, color: Colors.black87, size: 24),
                    splashRadius: 24,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LeaderboardScreen(email: widget.email,)),
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
                    'CityGram',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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

      // ✅ TabBarView wrapped with RefreshIndicator for pull-to-refresh
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ Local Feed Tab with Pull-to-Refresh
          RefreshIndicator(
            onRefresh: _fetchFeed, // ✅ Pulling down refreshes posts
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _buildCitySelector()), // City selector
                _buildFeedList(_posts.where((post) => post.city == _selectedCity && post.solved == "solved").toList()),
              ],
            ),
          ),

          // ✅ Nation Feed Tab with Pull-to-Refresh
          RefreshIndicator(
            onRefresh: _fetchFeed,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildFeedList(_posts),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0, email: widget.email),
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
                onLikeToggled: _handleUpvote,
                onShare: (postId) {
                  final post = posts.firstWhere((p) => p.id == postId);
                  _handleShare(post);
                }, // ✅ Correctly accepts postId and handles it
                onAuthorityTap: _handleTagClick,
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