import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/auth/pinterest_login.dart';

class PinterestService {
  final String clientId = dotenv.env['PINTEREST_CLIENT_ID'] ?? "MISSING_CLIENT_ID";
  final String clientSecret = dotenv.env['PINTEREST_CLIENT_SECRET'] ?? "MISSING_SECRET";
  final String redirectUri = dotenv.env['PINTEREST_REDIRECT_URI'] ?? "MISSING_REDIRECT_URI";

  final Logger _logger = Logger();

  // Always prompt user to choose Pinterest account
  String get authUrl =>
      "https://www.pinterest.com/oauth/?response_type=code"
      "&client_id=$clientId"
      "&redirect_uri=$redirectUri"
      "&scope=boards:read,pins:read,boards:write,pins:write"
      "&state=1234"
      "&prompt=consent";

  // Open Pinterest auth WebView
  Future<String?> authenticate(BuildContext context) async {
    await _clearPinterestSession(); // Clear old token first

    final authCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PinterestLogin(authUrl: authUrl),
      ),
    );

    if (authCode == null) {
      _logger.w("User cancelled Pinterest login.");
      return null;
    }

    _logger.i("Auth code received: $authCode");
    return authCode;
  }

  // Exchange Pinterest auth code for access token
  Future<String?> exchangeCodeForToken(String code) async {
    try {
      final encodedCredentials =
          base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse("https://api.pinterest.com/v5/oauth/token"),
        headers: {
          HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
        },
        body: "grant_type=authorization_code&code=$code&redirect_uri=$redirectUri",
      );

      _logger.i("Pinterest API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String accessToken = data["access_token"];

        // Save locally or in firestore for session storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("pinterest_access_token", accessToken);

        // Save in Firestore under user
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'pinterest_access_token': accessToken,
          }, SetOptions(merge: true));
        }

        _logger.i("Saved Access Token: $accessToken");
        return accessToken;
      } else {
        _logger.e("Token exchange failed: ${response.body}");
        return null;
      }
    } catch (e) {
      _logger.e("Exception during token exchange: $e");
      return null;
    }
  }

  // Load locally saved token
  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("pinterest_access_token");
  }

  // Fetch all Pinterest boards
  Future<List<Map<String, dynamic>>?> fetchUserBoards(String accessToken) async {
    List<Map<String, dynamic>> allBoards = [];
    String? nextPage = "https://api.pinterest.com/v5/boards";

    while (nextPage != null) {
      final response = await http.get(
        Uri.parse(nextPage),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        allBoards.addAll(List<Map<String, dynamic>>.from(data["items"]));

        nextPage = data["bookmark"] != null
            ? "https://api.pinterest.com/v5/boards?bookmark=${data['bookmark']}"
            : null;
      } else {
        _logger.e("Error fetching boards: ${response.body}");
        return null;
      }
    }

    _logger.i("Total Boards Retrieved: ${allBoards.length}");
    return allBoards;
  }

  // Clear token from local storage before login
  Future<void> _clearPinterestSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("pinterest_access_token");
    _logger.i("Cleared Pinterest token to force re-login.");
  }
}
