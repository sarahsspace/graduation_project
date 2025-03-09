import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/pinterest_service.dart';
import 'wardrobe_upload_screen.dart'; 
import 'connect_pinterest_screen.dart';
import 'package:flutter/cupertino.dart';
class SelectBoardScreen extends StatefulWidget {
  final String accessToken; 
  const SelectBoardScreen({super.key, required this.accessToken});

  @override
  _SelectBoardScreenState createState() => _SelectBoardScreenState();
}

class _SelectBoardScreenState extends State<SelectBoardScreen> {
  final PinterestService _pinterestService = PinterestService();
  List<Map<String, dynamic>> _boards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBoards();
  }

  // Fetch user's Pinterest boards
  void _fetchBoards() async {
    List<Map<String, dynamic>>? boards = await _pinterestService.fetchUserBoards(widget.accessToken);

    if (boards != null) {
      setState(() {
        _boards = boards;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showMessage("Failed to load boards.");
    }
  }

  //Save selected board to local storage
  void _saveSelectedBoard(String boardId, String boardName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("selected_board_id", boardId);
  await prefs.setString("selected_board_name", boardName);

  _showMessage("Selected board: $boardName");

  if (!mounted) return;
  
  //Pass accessToken to WardrobeUploadScreen
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => WardrobeUploadScreen(accessToken: widget.accessToken),
    ),
  );
}

  // Show snackbar message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _goBackToPinterestAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConnectPinterestScreen()),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:  AppBar(
        title: const Text(
          "Select a Pinterest Board",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 26),
          onPressed: _goBackToPinterestAuth,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Choose a board for outfit recommendations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _boards.length,
                      itemBuilder: (context, index) {
                        final board = _boards[index];
                        return Card(
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(board["name"], style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                              "Pins: ${board["pin_count"] ?? 'Unknown'}",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                            onTap: () => _saveSelectedBoard(board["id"], board["name"]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
