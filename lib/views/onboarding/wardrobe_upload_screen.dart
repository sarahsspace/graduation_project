import 'dart:ui'; // Import for blur effect
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_board_screen.dart';
import 'package:flutter/cupertino.dart';

class WardrobeUploadScreen extends StatelessWidget {
  final String accessToken;
  const WardrobeUploadScreen({super.key, required this.accessToken});

  Future<void> _clearSavedBoardAndGoBack(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove("selected_board_id");
  await prefs.remove("selected_board_name");

  if (!context.mounted) return;

  // Retrieve access token before navigating
  String? savedAccessToken = prefs.getString("pinterest_access_token");

  if (savedAccessToken == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error: Missing access token")),
    );
    return;
  }

  // Go back to SelectBoardScreen and pass the accessToken
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => SelectBoardScreen(accessToken: savedAccessToken),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/uploadWardrobe.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Frosted Bottom Sheet Effect
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30), // Adds margin
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 60), // Frosted effect
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                     color: Color(0xFFEAEAEA).withOpacity(0.3), 
                      borderRadius: BorderRadius.circular(30),
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          "Almost there!",
                          style: GoogleFonts.playfairDisplay(fontSize: 34, letterSpacing: 2, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Now just upload your wardrobe items.\n"
                          "The more items you upload, the more accurate\n"
                          "and diverse the recommendations will be!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Upload Buttons
                        ElevatedButton(
                          onPressed: () {}, // TODO: Implement camera functionality
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 20,), 
                              const SizedBox(width: 10),
                              Text("Take a Photo", style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {}, // TODO: Implement gallery selection
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 60),
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.photo_fill, color: Colors.white, size: 20,),
                              const SizedBox(width: 10),
                              Text("Upload from Gallery", style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back Button (Top Left)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
             icon: const Icon(CupertinoIcons.back, color: Colors.black, size: 30),
            onPressed: () => _clearSavedBoardAndGoBack(context),
            ),
          ),
        ],
      ),
    );
  }
}
