import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  final String location;
  final String photoUrl;
  final String heading;
  final String description;
  final List<String> authorities; // ✅ Multiple authorities

  const PostCard({
    Key? key,
    required this.location,
    required this.photoUrl,
    required this.heading,
    required this.description,
    this.authorities = const ["Public"], // ✅ Default to "Public" if empty
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int likeCount = 0;

  /// ✅ Load image from file or network
  Image _loadImage(String url) {
    return url.startsWith('/')
        ? Image.file(
            File(url),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 220,
          )
        : Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 220,
          );
  }

  /// ✅ Open Google Maps for location
  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    final Uri uri = Uri.parse(googleMapsUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open Maps for $address';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Location with clickable map redirection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openMap(widget.location),
                    child: Text(
                      widget.location,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Authorities like Instagram tags
          if (widget.authorities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.authorities.map((e) => '@$e').join(' '), // Space-separated @tags
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ✅ Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _loadImage(widget.photoUrl),
          ),

          // ✅ Heading, description, like section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading
                Text(
                  widget.heading,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  widget.description,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                // Like button with count
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                          likeCount += isLiked ? 1 : -1;
                        });
                      },
                    ),
                    Text('$likeCount Likes')
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
