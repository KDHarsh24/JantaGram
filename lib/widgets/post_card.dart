import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PostCardModel {
  final String id;
  final String city;
  final String cords;
  final String location;
  final String photoUrl;
  final Uint8List photoBlob;
  final String heading;
  final String description;
  final String solved;
  final List<String> authorities;
  final DateTime timestamp;
  final int initialLikeCount;
  final bool isInitiallyLiked;

  // ✅ Constructor (without const)
  PostCardModel({
    required this.id,
    required this.cords,
    required this.city,
    required this.location,
    required this.photoUrl,
    required this.heading,
    required this.description,
    required this.solved,
    required this.photoBlob,
    this.authorities = const ["Public"],
    required this.timestamp, // Removed default value
    this.initialLikeCount = 0,
    this.isInitiallyLiked = false,
  });

  // ✅ Factory constructor for creating an instance with the current timestamp
  factory PostCardModel.withTimestamp({
    required String id,
    required String cords,
    required String city,
    required String location,
    required String photoUrl,
    required String heading,
    required String description,
    required String solved, // ✅ Add solved
    List<String> authorities = const ["Public"],
    int initialLikeCount = 0,
    bool isInitiallyLiked = false,
    required Uint8List photoBlob,
  }) {
    return PostCardModel(
      id: id,
      cords: cords,
      city: city,
      location: location,
      photoUrl: photoUrl,
      heading: heading,
      description: description,
      solved: solved,
      authorities: authorities,
      timestamp: DateTime.now(), // ✅ Set current time dynamically
      initialLikeCount: initialLikeCount,
      isInitiallyLiked: isInitiallyLiked,
      photoBlob: photoBlob
    );
  }

  // ✅ Factory constructor for API JSON
  factory PostCardModel.fromJson(Map<String, dynamic> json) {
    return PostCardModel(
      id: json['post_Id'] ?? '',
      cords: json['cords'] ?? '',
      location: json['location'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      heading: json['heading'] ?? '',
      city: json['city'] ?? '',
      description: json['description'] ?? '',
      solved: json['solved'] ?? 'unsolved',
      authorities: List<String>.from(json['authorities'] ?? json["authority"]?? ['Public']),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      initialLikeCount: json['total_likes'] ?? 0,
      isInitiallyLiked: json['like'] ?? false,
      photoBlob: base64Decode(json['image_data'][0]['data'])
    );
  }

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'photoUrl': photoUrl,
      'heading': heading,
      'description': description,
      'solved': solved,
      'authorities': authorities,
      'timestamp': timestamp.toIso8601String(),
      'likeCount': initialLikeCount,
      'isLikedByUser': isInitiallyLiked,
      'photoBlob' : photoBlob
    };
  }
}

class PostCard extends StatefulWidget {
  final PostCardModel post;
  final Function(String postId, bool isLiked)? onLikeToggled;
  final Function(String postId)? onShare;
  final Function(String postId)? onLocationTap;
  final Function(String postId)? onTap;
  final Function(String authority)? onAuthorityTap;
  final Function(String authority)? doubleTap;
  const PostCard({
    super.key,
    required this.post,
    this.onLikeToggled,
    this.onShare,
    this.onLocationTap,
    this.onTap,
    this.onAuthorityTap,
    this.doubleTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late bool isLiked;
  late int likeCount;
  late AnimationController _likeController;
  
  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isInitiallyLiked;
    likeCount = widget.post.initialLikeCount;
    
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

Widget _loadImage(Uint8List? photoBlob) {
  // ✅ If blob is null or empty, show placeholder
  if (photoBlob == null) {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }

  // ✅ Load image from memory
  return ClipRRect(
    borderRadius: BorderRadius.circular(8), // Optional rounded corners
    child: Image.memory(
                photoBlob, // ✅ Display from blob
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover, // Cover fit
        ),
  );
}


  Future<void> _openMap(String coordinates) async {
    try {
      final query = Uri.encodeComponent(coordinates); // Coordinates like "26.9124,75.7873"
      final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$query";
      final Uri uri = Uri.parse(googleMapsUrl);

      // Handle custom location tap event if provided
      if (widget.onLocationTap != null) {
        widget.onLocationTap!(widget.post.id);
        return;
      }

      // Try launching Google Maps
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not open Maps for coordinates $coordinates';
      }
    } catch (e) {
      debugPrint('Error opening map: $e');
    }
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
      
      if (isLiked) {
        _likeController.forward(from: 0.0);
      }
    });
    
    // Notify parent about like toggle
    if (widget.onLikeToggled != null) {
      widget.onLikeToggled!(widget.post.id, isLiked);
    }
  }

  String _getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(widget.post.timestamp);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(widget.post.timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.post.id) : null,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timestamp & Menu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timestamp
                  Text(
                    _getRelativeTime(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  // Menu button
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                ],
              ),
            ),

            // Location with map redirection
            if (widget.post.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: theme.colorScheme.secondary, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openMap(widget.post.cords),
                        child: Text(
                          widget.post.location,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Authorities like Instagram tags
            if (widget.post.authorities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Wrap(
                  spacing: 4,
                  children: widget.post.authorities.map(
                    (authority) => GestureDetector(
                      onTap: widget.onAuthorityTap != null 
                          ? () => widget.onAuthorityTap!(authority)
                          : null,
                      child: Text(
                        '@$authority',
                        style: TextStyle(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ).toList(),
                ),
              ),

            // Image
            Hero(
              tag: 'post_image_${widget.post.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(0),
                  bottom: Radius.circular(6),
                ),
                child: GestureDetector(
                  onDoubleTap: _toggleLike, // ✅ Double tap to upvote
                  child: _loadImage(widget.post.photoBlob),
                ),
              ),
            ),

            // Heading, description, actions section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    widget.post.heading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Description
                  Text(
                    widget.post.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Like button animation
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                          CurvedAnimation(
                            parent: _likeController, 
                            curve: Curves.elasticOut
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          onPressed: _toggleLike,
                          splashRadius: 20,
                        ),
                      ),
                      Text(
                        '$likeCount ${likeCount == 1 ? 'Like' : 'Likes'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Share button
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.grey[600]),
                        onPressed: widget.onShare != null 
                            ? () => widget.onShare!(widget.post.id)
                            : null,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}