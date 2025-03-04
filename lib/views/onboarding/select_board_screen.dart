import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/pinterest_service.dart';

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

  // Save selected board to local storage
  void _saveSelectedBoard(String boardId, String boardName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_board_id", boardId);
    await prefs.setString("selected_board_name", boardName);

    _showMessage("Selected board: $boardName");

    // Navigate back after selection
    if (!mounted) return;
    Navigator.pop(context, {"id": boardId, "name": boardName});
  }

  // Show snackbar message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Select a Pinterest Board")),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Choose a board for outfit recommendations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Expanded( // Makes listView scrollable
                  child: ListView.builder(
                    itemCount: _boards.length,
                    itemBuilder: (context, index) {
                      final board = _boards[index];
                      return ListTile(
                        title: Text(board["name"]),
                        subtitle: Text("Pins: ${board["pin_count"] ?? 'Unknown'}"),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => _saveSelectedBoard(board["id"], board["name"]),
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
