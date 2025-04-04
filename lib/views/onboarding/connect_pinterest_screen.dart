import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/services/auth_service.dart';
import '../../services/pinterest_service.dart';
import 'package:logger/logger.dart';
import '../onboarding/select_board_screen.dart';
import '../auth/login_screen.dart';

class ConnectPinterestScreen extends StatefulWidget {
  const ConnectPinterestScreen({super.key});
  @override
  _ConnectPinterestScreenState createState() => _ConnectPinterestScreenState();
}

class _ConnectPinterestScreenState extends State<ConnectPinterestScreen> {
  final PinterestService _pinterestService = PinterestService();
  String? _accessToken;
  final Logger _logger = Logger();

  void _connectToPinterest() async {
  String? code = await _pinterestService.authenticate(context);

  if (code != null) {
    String? token = await _pinterestService.exchangeCodeForToken(code);

    if (token != null) {
      setState(() {
        _accessToken = token;
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SelectBoardScreen(accessToken: token)),
      );
    } else {
      _logger.e("Failed to get access token.");
    }
  } else {
    _logger.w("Pinterest authentication failed.");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/connectPinBckg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Text(
                  "Welcome to",
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                Text(
                  "MUSE",
                  style: GoogleFonts.playfairDisplay(fontSize: 34, letterSpacing: 2, color: Colors.white),
                ),
                const SizedBox(height: 30),
                Text(
                  "Connect your\nPinterest account\nto personalize\nyour experience.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/pinLogo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: _connectToPinterest,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: const Color.fromARGB(255, 168, 4, 31),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.link, color: Colors.white),
                      const SizedBox(width: 10),
                      Text("Connect to Pinterest", style: GoogleFonts.poppins(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final authService = AuthService();
                    await authService.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => LoginScreen()), 
                      );
                  },child:
                  Text("Not your account? Log out",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 16, 
                      color: Colors.white.withOpacity(0.9),
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white),
                ),
                ),
                
                if (_accessToken != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    "Connected to Pinterest!",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  // SelectableText("Token: $_accessToken"),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
