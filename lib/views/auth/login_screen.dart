import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../onboarding/connect_pinterest_screen.dart';
import 'signup_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); 
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService(); //Initialize AuthService

  
  // Function to handle login
void _handleLogin() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showMessage("Please enter email and password");
    return;
  }

  User? user = await _authService.login(email, password);

  if (user != null) {
    _showMessage("Login Successful!");
    
    // Navigate to Pinterest Connect Screen
    if (!mounted) return; 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConnectPinterestScreen()),
    );

  } else {
    _showMessage("Login Failed. Check your credentials.");
  }
}


  // Function to show a message on screen
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(fontSize: 16))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.black, 
      elevation: 0, 
      toolbarHeight: 3, 
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome to", style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500)),
            Text(
              "MUSE",
              style: GoogleFonts.playfairDisplay(fontSize: 34, letterSpacing: 2),
            ),
            SizedBox(height: 20),
            Text("Log in to continue", style: GoogleFonts.poppins(fontSize: 16)),
            SizedBox(height: 30),

            // Email input
            Text("Email", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(45)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),

            // Password input
            Text("Password", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(45)),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 25),

            // Login Button 
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
              ), child: Text("Login", style: GoogleFonts.poppins(fontSize: 16)),
            ),
            SizedBox(height: 15),

            // Google Sign-In Placeholder
           ElevatedButton(
  onPressed: () async {
    AuthService authService = AuthService();
    User? user = await authService.signInWithGoogle();

    if (user != null) {
      print("Google Sign-In Successful: ${user.displayName}");
     if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnectPinterestScreen()),
      );
    } else {
      print("Google Sign-In Failed");
    }
  },
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 50),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/googleLogo.jpg',
        width: 30,  
        height: 30,
      ),
      SizedBox(width: 10),
      Text("Continue with Google", style: GoogleFonts.poppins(fontSize: 16)),
    ],
  ),
),

            SizedBox(height: 25),

            // Sign up link
            Center(
              child: GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  },
  child: Text(
    "Don't have an account? Sign up",
    style: GoogleFonts.poppins(
      fontSize: 14,
      decoration: TextDecoration.underline,
    ),
  ),
),
            ),
          ],
        ),
      ),
    );
  }
}
