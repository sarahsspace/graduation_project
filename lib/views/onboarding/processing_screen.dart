import 'package:flutter/material.dart';

class ProcessingScreen extends StatelessWidget {
  final String accessToken;

  const ProcessingScreen({Key? key, required this.accessToken})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processing'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'All done! Please give us 5 minutes to process. You can then use your app.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
