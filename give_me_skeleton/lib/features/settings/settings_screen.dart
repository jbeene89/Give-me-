import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Monetization stubs'),
            subtitle: Text('IAP/Ads are wired but require Play Console + AdMob setup.'),
          ),
          Divider(),
          ListTile(
            title: Text('Tuning'),
            subtitle: Text('Edit core/state/turn_engine.dart to change how the world behaves.'),
          ),
        ],
      ),
    );
  }
}
