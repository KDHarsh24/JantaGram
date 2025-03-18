import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../Config.dart';
import 'home_screen.dart'; // Your API URLs

class RegisterPage extends StatefulWidget {
  final String email; // Email passed from login page
  
  const RegisterPage({Key? key, required this.email}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isPressed = false;
  bool isLoading = false;
  String errorMessage = '';
  String _city = "Detecting city..."; // For auto-detected city

  @override
  void initState() {
    super.initState();
    _getLocation(); // Fetch location when page opens
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// ✅ Get Location and set city
  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _city = "Location services disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _city = "Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _city = "Location permission permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? "Unknown City";
        setState(() => _city = city);
      } else {
        setState(() => _city = "City not found");
      }
    } catch (e) {
      setState(() => _city = "Error fetching city");
    }
  }

  /// ✅ Register user with name, bio, and city
  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final String name = _nameController.text.trim();
    final String bio = _bioController.text.trim();

    if (name.isEmpty || bio.isEmpty) {
      setState(() {
        errorMessage = 'Name and Bio cannot be empty!';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'name': name,
          'bio': bio,
          'city': _city, // ✅ Send detected city
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
  // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Navigate to HomeScreen or another page after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(email: widget.email)),
          );
        });
      }
       else {
        setState(() {
          errorMessage = responseData['message'] ?? 'Failed to register.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // Heading with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.location_city, // City icon
                    color: Colors.deepPurple, // You can customize color
                    size: 34, // Icon size
                  ),
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    'CityGram',
                    style: TextStyle(
                      fontSize: 32, // Bigger funky heading
                      fontWeight: FontWeight.w900, // Bold and thick
                      color: Colors.deepPurple, // Same as icon color
                      letterSpacing: 1.5, // Optional spacing for style
                      fontFamily: 'Poppins', // Optional modern font
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subtitle
              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 30),

            // Email (readonly)
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.email),
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 20),

            // Name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 20),

            // Bio input
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Short Bio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.edit_note_outlined),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 20),

            // Auto-detected City (readonly)
            TextField(
              enabled: false,
              controller: TextEditingController(text: _city),
              decoration: InputDecoration(
                labelText: 'Location (auto-detect)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.location_city_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 20),

            // Error message display
            if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Register button
            isLoading
                ? const CircularProgressIndicator(color: Colors.orange)
                : GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),  // Shrink when pressed
                  onTapUp: (_) => setState(() => _isPressed = false),  // Back to normal when released
                  onTapCancel: () => setState(() => _isPressed = false), // Reset if cancelled
                  onTap: registerUser, // Your function to call
                  child: AnimatedScale(
                    scale: _isPressed ? 0.95 : 1.0, // Shrink effect on tap
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color.fromARGB(255, 64, 70, 255), Color.fromARGB(255, 236, 64, 255)], // Funky gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10), // Fully rounded button
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.4), // Glowy shadow
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'REGISTER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900, // Extra bold
                          fontSize: 18,
                          letterSpacing: 2, // Funky spacing
                          fontFamily: 'Poppins', // Optional modern font
                        ),
                      ),
                    ),
                  ),
                )
          ],
        ),
      ),
    );
  }
}
