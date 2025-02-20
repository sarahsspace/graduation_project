import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Toggle for password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome to", 
            style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500),
                       ),
            Text(
              "MUSE",
              style: GoogleFonts.playfairDisplay(
                fontSize: 34,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 20),
            Text("Log in to continue", style: GoogleFonts.poppins(fontSize: 16)),
            SizedBox(height: 30),

            //email input
            Text(
              "Email",
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),

            //password input
            Text(
              "Password",
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 25),

            // login btn 
             ElevatedButton(
              onPressed: () {},
              child: Text("Login", style: GoogleFonts.poppins(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
            ),
            SizedBox(height: 15),

            //google sign in btn placeholder now
            ElevatedButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_translate, color: Colors.black),
                  SizedBox(width: 10),
                  Text("Continue with Google", style: GoogleFonts.poppins(fontSize: 16)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
            ),
            SizedBox(height:25),

            //sign up link
            Center(
              child: GestureDetector(
                onTap:() {},
                child: Text(
                  "Dont have an account? Sign up",
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