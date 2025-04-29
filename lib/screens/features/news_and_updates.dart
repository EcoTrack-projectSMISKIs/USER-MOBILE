import 'package:flutter/material.dart';

class NewsAndUpdates extends StatelessWidget {
  const NewsAndUpdates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News And Updates')),
      body: const Center(child: Text('News and Updates Page')),
    );
  }
}
