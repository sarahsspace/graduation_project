import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pinterest_service.dart';

class ConnectPinterestScreen extends StatefulWidget {
  @override
  _ConnectPinterestScreenState createState() => _ConnectPinterestScreenState();
}

class _ConnectPinterestScreenState extends State<ConnectPinterestScreen> {
  final PinterestService _pinterestService = PinterestService();
  String? _accessToken;

  void _connectToPinterest() async {
    String? code = await _pinterestService.authenticate(context);
    if (code != null) {
      String? token = await _pinterestService.exchangeCodeForToken(code);
      if (token != null) {
        setState(() {
          _accessToken = token;
        });
        print("Pinterest Access Token: $_accessToken");
      } else {
        print("Failed to get access token.");
      }
    } else {
      print("Pinterest authentication failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome to MUSE",
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Text(
              "Connect your Pinterest account to personalize your experience.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/0/08/Pinterest-logo.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _connectToPinterest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Connect to Pinterest", style: GoogleFonts.poppins(fontSize: 16)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
            ),

            if (_accessToken != null) ...[
              SizedBox(height: 20),
              Text(
                "Connected to Pinterest!",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SelectableText("Token: $_accessToken"),
            ]
          ],
        ),
      ),
    );
  }
}
