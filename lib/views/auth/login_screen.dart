import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome to MUSEE", 
            style: TextStyle(fontSize:28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Log in to continue", style: TextStyle(fontSize:16)),
            SizedBox(height: 30),

            //email input
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),

            //password input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // login btn 
            ElevatedButton(
              onPressed:(){},
              child: Text("Login"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),

            //google sign in btn placeholder now
            ElevatedButton(
              onPressed:(){},
              child: Text("Login with Google"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.redAccent,
              ),
            ),
            SizedBox(height:20),

            //sign up link
            Center(
              child: GestureDetector(
                onTap:() {},
                child: Text(
                  "Dont have an account? Sign up",
                  style: TextStyle(
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