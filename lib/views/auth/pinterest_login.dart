import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PinterestLogin extends StatefulWidget {
  final String authUrl;
  const PinterestLogin({super.key, required this.authUrl});

  @override
  _PinterestLoginState createState() => _PinterestLoginState();
}

class _PinterestLoginState extends State<PinterestLogin> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _clearCookies(); // Clears previous session cookies
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
            if (request.url.startsWith(dotenv.env['PINTEREST_REDIRECT_URI']!)) {
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

  // Function to clear cookies before authentication
  Future<void> _clearCookies() async {
    final cookieManager = WebViewCookieManager(); // Flutter's WebView Cookie Manager
    await cookieManager.clearCookies();
    debugPrint("WebView cookies cleared"); // Debug message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pinterest Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
