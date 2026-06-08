import 'package:baalkatwao/routes/routes.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.keyboard_arrow_right),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(context, Routes.changepasspage);
            },
          ),
        ],
      ),
    );
  }
}
