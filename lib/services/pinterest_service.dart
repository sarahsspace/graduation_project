import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class PinterestService {
  final String clientId = dotenv.env['PINTEREST_CLIENT_ID'] ?? "MISSING_CLIENT_ID";
  final String clientSecret = dotenv.env['PINTEREST_CLIENT_SECRET'] ?? "MISSING_SECRET";
  final String redirectUri = dotenv.env['PINTEREST_REDIRECT_URI'] ?? "MISSING_REDIRECT_URI";

  final String authUrl =
      "https://www.pinterest.com/oauth/?response_type=code&client_id=${dotenv.env['PINTEREST_CLIENT_ID']}&redirect_uri=${dotenv.env['PINTEREST_REDIRECT_URI']}&scope=boards:read,pins:read,boards:write,pins:write&state=1234";
      
  // Authenticate user through WebView
  Future<String?> authenticate(BuildContext context) async {
    String? authCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PinterestLoginWebView(authUrl)),
    );

    if (authCode == null) {
      print("User cancelled login");
      return null;
    }
    return authCode;
  }

  // Exchange authorization code for access token
  Future<String?> exchangeCodeForToken(String code) async {
    try {
      String credentials = "$clientId:$clientSecret";
      String encodedCredentials = base64Encode(utf8.encode(credentials));

      final response = await http.post(
        Uri.parse("https://api.pinterest.com/v5/oauth/token"),
        headers: {
          HttpHeaders.authorizationHeader: "Basic $encodedCredentials",
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
        },
        body: "grant_type=authorization_code"
              "&code=$code"
              "&redirect_uri=$redirectUri",
      );

      print("Pinterest API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String accessToken = data["access_token"];

        // Save access token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("pinterest_access_token", accessToken);

        print("Access Token: $accessToken");
        return accessToken;
      } else {
        print("Token Exchange Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during token exchange: $e");
      return null;
    }
  }

  // Retrieve saved access token
  Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("pinterest_access_token");
  }
}

// WebView for Pinterest login
class PinterestLoginWebView extends StatefulWidget {
  final String authUrl;
  PinterestLoginWebView(this.authUrl);

  @override
  _PinterestLoginWebViewState createState() => _PinterestLoginWebViewState();
}

class _PinterestLoginWebViewState extends State<PinterestLoginWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("museapp://auth/callback")) {
              Uri uri = Uri.parse(request.url);
              String? code = uri.queryParameters['code'];

              // Close WebView and return auth code
              Navigator.pop(context, code);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pinterest Login")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
