import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            title: 'Business Info',
            children: [
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Business Details'),
                subtitle: const Text('Name, GSTIN, Address'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Print Settings'),
                subtitle: const Text('A4, Thermal, Headers'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ]
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: 'Data & Sync',
            children: [
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Manual Sync'),
                subtitle: const Text('Force sync with cloud'),
                trailing: const Icon(Icons.cloud_upload),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing...')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup Data'),
                subtitle: const Text('Create local backup of Hive Database'),
                trailing: const Icon(Icons.save_alt),
                onTap: () {},
              ),
            ]
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: 'App Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Theme'),
                trailing: Switch(value: false, onChanged: (v) {}),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ]
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: children,
          ),
        )
      ],
    );
  }
}
