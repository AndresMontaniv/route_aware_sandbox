import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'push_example.dart';

class ExampleScreen extends StatelessWidget {
  static const name = 'example';

  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          const Text('This is the Example Screen'),
          const FlutterLogo(size: 200),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.pushNamed(PushExampleScreen.name);
            },
            child: const Text('Push Example'),
          ),
        ],
      ),
    );
  }
}
