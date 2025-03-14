import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class AddPostScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostAdded;

  const AddPostScreen({Key? key, required this.onPostAdded}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  final _titleController = TextEditingController();
  String _location = "Fetching location...";
  String _resolvedAddress = "Fetching address...";
  String _city = "Fetching city..."; // Add this on top as a state variable
  final List<String> _authorities = [
    "Municipal Department",
    "Police Department",
    "Public Works Department",
    "Health Department",
    "Environment Department",
  ];
  final List<String> _selectedAuthorities = [];

  @override
  void initState() {
    super.initState();
    _initProcess();
  }

  /// Initial combined process for permissions, location, and image
  Future<void> _initProcess() async {
    await _requestPermissions();
    await _pickImage();
    await _getLocation();
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

  /// Pick Image from Camera safely
  Future<void> _pickImage() async {
    final status = await Permission.camera.request();

    if (status.isDenied) {
      setState(() => _location = "Camera permission denied.");
      return;
    } else if (status.isPermanentlyDenied) {
      setState(() => _location = "Camera permission permanently denied. Enable it in settings.");
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    } else {
      setState(() => _location = "No image captured.");
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
    setState(() => _location = "${position.latitude}, ${position.longitude}");

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

      // Detect city
      String city = place.locality ?? place.subAdministrativeArea ?? "Unknown City";

      setState(() {
        _resolvedAddress = address;
        _city = "$city, India"; // Format city properly
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
      }
    });
  }

  /// Handle Upload Post
  /// Handle Upload Post
void _handleUpload() {
  if (_image != null && _titleController.text.isNotEmpty) {
    widget.onPostAdded({
      "city": _city, // Add city here
      "location": _resolvedAddress,
      "photoUrl": _image!.path,
      "heading": _titleController.text,
      "description": "Reported via App", 
      "authorities": _selectedAuthorities,
    });
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Please capture an image and fill the title.")));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _image != null
                ? Image.file(_image!, height: 250, width: double.infinity, fit: BoxFit.cover)
                : const Text("No image captured yet.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title / Heading", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text("Tag Authorities:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _authorities.map((authority) {
                final isSelected = _selectedAuthorities.contains(authority);
                return ChoiceChip(
                  label: Text(authority),
                  selected: isSelected,
                  onSelected: (_) => _toggleAuthority(authority),
                  selectedColor: Colors.blue.shade300,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_resolvedAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text("($_location)", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleUpload,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Post"),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
