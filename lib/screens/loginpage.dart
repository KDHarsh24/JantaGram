import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'registerpage.dart';
import 'home_screen.dart';
import 'home_screen_dept.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool otpSent = false;
  bool emailEnabled = true;
  bool isLoading = false;
  String errorMessage = '';
  Timer? _resendTimer;
  int _timeLeft = 0;
  final Map<String, String> _cookies = {};
  
  // Add animation controller for error state
  late AnimationController _errorController;
  bool _isOtpError = false;

  @override
  void initState() {
    super.initState();
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  void startResendTimer() {
    const int resendDelay = 60;
    setState(() => _timeLeft = resendDelay);
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _updateCookies(http.Response response) {
    String? rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      List<String> cookies = rawCookies.split(',');
      for (var cookie in cookies) {
        List<String> cookieParts = cookie.split(';')[0].split('=');
        if (cookieParts.length == 2) {
          _cookies[cookieParts[0].trim()] = cookieParts[1].trim();
        }
      }
    }
  }

  String get _cookieHeader {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  Future<void> sendOTP() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      _isOtpError = false;
    });

    try {
      String email = _emailController.text.trim();
      if (email.isEmpty) {
        throw Exception('Please enter your email');
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          if (_cookieHeader.isNotEmpty) 'Cookie': _cookieHeader,
        },
        body: json.encode({'email': email}),
      );

      _updateCookies(response);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        setState(() {
          otpSent = true;
          emailEnabled = false;
        });
        startResendTimer();
        _showSuccessMessage('OTP sent successfully');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
      _showErrorMessage(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyOTP() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      String email = _emailController.text.trim();
      String otp = _otpController.text.trim();

      if (otp.isEmpty) {
        throw Exception('Please enter OTP');
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          if (_cookieHeader.isNotEmpty) 'Cookie': _cookieHeader,
        },
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('sessionCookies', _cookieHeader);
        print(email);
        if (responseData['depart'] == "d"){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreenDept(email: email)),
            );
        }
        else{
        switch (responseData['isNewUser']) {
          case true:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage(email: email)),
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(email: email),
              ),
            );
        }
        }
      } else {
        setState(() => _isOtpError = true);

        throw 'Invalid OTP. Please try again.';
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
      _showErrorMessage(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 45),
            
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.deepPurple, size: 28), // ✅ Location icon
              const SizedBox(width: 6),
              Text(
                "CityGram",
                style: TextStyle(
                  fontSize: 32, // ✅ Large beautiful font size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins', // ✅ Make sure this font is added in pubspec.yaml
                  color: Colors.deepPurple, // ✅ Stylish color
                  letterSpacing: 1.5, // ✅ Slight spacing for elegance
                ),
              ),
            ],
          ),
            
            const SizedBox(height: 40),
            
            if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
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
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            TextField(
              controller: _emailController,
              enabled: emailEnabled,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofillHints: const [AutofillHints.email],
            ),
            
            const SizedBox(height: 20),
            
            if (otpSent)
              AnimatedBuilder(
                animation: _errorController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_errorController.value * 20, 0),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isOtpError ? Colors.red : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _isOtpError 
                              ? Colors.red 
                              : Theme.of(context).primaryColor,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: _isOtpError ? Colors.red : null,
                        ),
                        filled: true,
                        fillColor: _isOtpError 
                          ? Colors.red.shade50 
                          : Colors.grey.shade50,
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 20),
            
            if (isLoading)
              const SpinKitFadingCube(color: Colors.orange, size: 50.0)
            else if (!otpSent)
              ElevatedButton(
                onPressed: sendOTP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: verifyOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Verify OTP',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_timeLeft > 0)
                    Text(
                      'Resend OTP in $_timeLeft seconds',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          otpSent = false;
                          emailEnabled = true;
                          _otpController.clear();
                        });
                        sendOTP();
                      },
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}