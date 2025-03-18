import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import '../config.dart';
import 'package:http/http.dart' as http;

class AddPostScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostAdded;
  String email;
  AddPostScreen({super.key, required this.onPostAdded, required this.email});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> with SingleTickerProviderStateMixin {
  File? _image;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController(text: "Reported via App");
  String _location = "Fetching location...";
  String _resolvedAddress = "Fetching address...";
  String _city = "Fetching city...";
  bool _isLoading = true;
  bool _previewMode = false;
  late AnimationController _animationController;
  Uint8List? _imageBlob; 
  String _selectedStatus = "unsolved"; // ✅ Initialize status variable
  
  final List<String> _authorities = [
    "Municipality",
    "Police Department",
    "Public Works Department",
    "HealthCare",
    "Environment Department",
  ];
  final List<String> _selectedAuthorities = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initProcess();
  }
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Initial combined process for permissions, location, and image
  Future<void> _initProcess() async {
    setState(() => _isLoading = true);
    await _requestPermissions();
    await _getLocation();
    await _pickImage();
    setState(() => _isLoading = false);
  }

  /// Request permissions for camera and location
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.camera]!.isDenied) {
      setState(() => _location = "Camera permission denied.");
    }

    if (statuses[Permission.locationWhenInUse]!.isDenied) {
      setState(() => _location = "Location permission denied.");
    }
  }
  
  Future<void> _pickImage() async {
  // Request camera permission
  final status = await Permission.camera.request();
  if (status.isDenied) {
    debugPrint("Camera permission denied.");
    return;
  } else if (status.isPermanentlyDenied) {
    debugPrint("Camera permission permanently denied. Enable it in settings.");
    return;
  }

  // Pick image from camera
  final pickedFile = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 85, // Optional: Compress image
    maxWidth: 1200,  // Optional: Limit width
  );

  if (pickedFile != null) {
    final File imageFile = File(pickedFile.path);
    final Uint8List imageBytes = await imageFile.readAsBytes(); // ✅ Convert to Blob (bytes)

    setState(() {
      _image = imageFile;   // For preview if needed
      _imageBlob = imageBytes; // ✅ Store as Blob in variable
    });

    debugPrint('✅ Image picked. Blob size: ${imageBytes.lengthInBytes} bytes');
  } else {
    debugPrint("No image selected.");
  }
}


  /// Get Location and Address with City Detection
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _location = "Enable location services.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _location = "Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _location = "Location permission permanently denied. Go to settings to enable.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "${position.latitude}, ${position.longitude}";
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address = "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}";
      address = address.replaceAll(RegExp(r'(, )+'), ', ').replaceAll(RegExp(r'^, |, $'), '');

      // Detect city
      String city = place.locality ?? place.subAdministrativeArea ?? "Unknown City";

      setState(() {
        _resolvedAddress = address;
        _city = city; // Format city properly
      });
    } else {
      setState(() {
        _resolvedAddress = "No address found.";
        _city = "Unknown City";
      });
    }
  }

  /// Authority Selection
  void _toggleAuthority(String authority) {
    setState(() {
      if (_selectedAuthorities.contains(authority)) {
        _selectedAuthorities.remove(authority);
      } else {
        _selectedAuthorities.add(authority);
        _animationController.forward(from: 0.0);
      }
    });
  }

  /// Toggle preview mode
  void _togglePreview() {
    setState(() {
      _previewMode = !_previewMode;
    });
  }

  /// Handle Upload Post
  Future<void> _handleUpload() async {
    if (_image != null && _titleController.text.isNotEmpty) {
      Map<String, dynamic> data  = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "city": _city,
        "cords": _location,
        "location": _resolvedAddress,
        "photoUrl": base64Encode(_imageBlob!),
        "heading": _titleController.text,
        "description": _descriptionController.text,
        "authorities": _selectedAuthorities,
        "timestamp": DateTime.now().toIso8601String(),
        "isLikedByUser": false,
        "email": widget.email
      };
      final String url = '${Config.baseUrl}/posts/create';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
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
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture an image and fill the title.")),
      );
    }
  }

  String _getRelativeTime() {
    return 'Just now';
  }

  Widget _buildPreview() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Preview Mode",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _togglePreview,
                child: const Text("Exit Preview"),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
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
              if (_resolvedAddress.isNotEmpty && _resolvedAddress != "Fetching address..." && _resolvedAddress != "No address found.")
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: theme.colorScheme.secondary, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _resolvedAddress,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Authorities like Instagram tags
              if (_selectedAuthorities.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Wrap(
                    spacing: 4,
                    children: _selectedAuthorities.map(
                      (authority) => Text(
                        '@$authority',
                        style: TextStyle(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ).toList(),
                  ),
                ),

              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(0),
                  bottom: Radius.circular(6),
                ),
                child: _imageBlob != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
                    child: Image.memory(
                      _imageBlob!, // ✅ Display from blob
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover, // Cover fit
                    ),
                  )
                    : Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
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
                      _titleController.text.isEmpty ? "Your Title Will Appear Here" : _titleController.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Description
                    Text(
                      _descriptionController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Action Buttons
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.grey[600],
                          ),
                          onPressed: null,
                          splashRadius: 20,
                        ),
                        Text(
                          '0 Likes',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Share button
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.grey[600]),
                          onPressed: null,
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
      ],
    );
  }

  Widget _buildEditForm() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with take photo button
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: _imageBlob != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                         ClipRRect(
                          borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
                          child: Image.memory(
                            _imageBlob!, // ✅ Display from blob
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover, // Cover fit
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Tap to change photo",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 3.0,
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(1.0, 1.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                                              ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to take a photo",
                        style: TextStyle(
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
            ),
          ),

          const SizedBox(height: 16),

          // Title input field
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Description input field
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),
 
          // Status selection dropdown
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
            items: ["unsolved", "inprogress", "solved"].map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status[0].toUpperCase() + status.substring(1)),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: "Status",
              border: OutlineInputBorder(),
            ),
          ),
 
          const SizedBox(height: 16),
 
          // Authorities selection
          Text("Select Authorities:", style: theme.textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: _authorities.map((authority) {
              return ChoiceChip(
                label: Text(authority),
                selected: _selectedAuthorities.contains(authority),
                onSelected: (selected) {
                  _toggleAuthority(authority);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Location display
          Text(
            "cords: $_location",
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            "Location: $_resolvedAddress",
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            "City: $_city",
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),

          // Upload button
          Center(
            child: ElevatedButton(
              onPressed: _handleUpload,
              child: const Text("Upload Post"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post"),
        actions: [
          IconButton(
            icon: Icon(_previewMode ? Icons.edit : Icons.preview),
            onPressed: _togglePreview,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _previewMode ? _buildPreview() : _buildEditForm(),
    );
  }
}