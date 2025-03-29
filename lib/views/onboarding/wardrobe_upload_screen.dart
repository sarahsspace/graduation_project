import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_board_screen.dart';
import 'processing_screen.dart';

class WardrobeUploadScreen extends StatefulWidget {
  final String accessToken;
  const WardrobeUploadScreen({super.key, required this.accessToken});

  @override
  State<WardrobeUploadScreen> createState() => _WardrobeUploadScreenState();
}

class _WardrobeUploadScreenState extends State<WardrobeUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _wardrobeImages = [];
  static const int maxImageLimit = 100;

  // Take one photo and add to the list
  Future<void> _takePhoto() async {
    if (_wardrobeImages.length >= maxImageLimit) return;

    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _wardrobeImages.add(File(picked.path));
      });
    }
  }

  // Select multiple from gallery
  Future<void> _pickImagesFromGallery() async {
    if (_wardrobeImages.length >= maxImageLimit) return;

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      final newFiles = pickedFiles
          .take(maxImageLimit - _wardrobeImages.length)
          .map((e) => File(e.path))
          .toList();

      setState(() {
        _wardrobeImages.addAll(newFiles);
      });
    }
  }

  // Back button clears board and goes to previous screen
  Future<void> _clearSavedBoardAndGoBack(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("selected_board_id");
    await prefs.remove("selected_board_name");

    if (!context.mounted) return;

    final String? token = prefs.getString("pinterest_access_token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Missing access token")),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SelectBoardScreen(accessToken: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _wardrobeImages.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/uploadWardrobe.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Bottom frosted glass container
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 60),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Almost there!",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 34,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
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

                        // Take a Photo Button
                        ElevatedButton(
                          onPressed: _takePhoto,
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
                              const Icon(CupertinoIcons.camera_fill, color: Colors.white),
                              const SizedBox(width: 10),
                              Text("Take a Photo", style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Upload from Gallery Button
                        ElevatedButton(
                          onPressed: _pickImagesFromGallery,
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
                              const Icon(CupertinoIcons.photo_fill, color: Colors.white),
                              const SizedBox(width: 10),
                              Text("Upload from Gallery", style: GoogleFonts.poppins(fontSize: 16)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Continue Button
                        ElevatedButton(
                          onPressed: canContinue
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProcessingScreen(
                                        accessToken: widget.accessToken,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45),
                            ),
                          ),
                          child: Text("Continue", style: GoogleFonts.poppins(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Back Button Top Left
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
