import 'package:flutter/material.dart';

class PushExampleScreen extends StatelessWidget {
  static const name = 'push_example';

  const PushExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PushExample')),
      body: const Center(child: FlutterLogo(size: 300)),
    );
  }
}
