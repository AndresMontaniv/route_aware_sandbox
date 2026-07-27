import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const name = 'profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Column(
        children: [
          Text('This is the Profile screen'),
        ],
      ),
    );
  }
}
