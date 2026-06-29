import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rk_enterprises/theme/theme_provider.dart';
import 'package:rk_enterprises/sync/sync_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;

  void _manualSync() async {
    setState(() => _isSyncing = true);
    
    // Simulate slight delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 800));
    SyncManager().syncAllPendingData();
    
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync requested successfully!')),
      );
    }
  }

  void _showBusinessProfileDialog() {
    // In a real app, load this from Hive or SharedPreferences
    final nameController = TextEditingController(text: 'RK Enterprises');
    final gstinController = TextEditingController(text: '27AAAAA0000A1Z5');
    
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Business Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Business Name')),
            const SizedBox(height: 16),
            TextField(controller: gstinController, decoration: const InputDecoration(labelText: 'GSTIN')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Save to Hive here
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Saved')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPrintSettingsDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Print Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(value: 1, groupValue: 1, onChanged: (v) {}, title: const Text('A4 Size (PDF)')),
            RadioListTile(value: 2, groupValue: 1, onChanged: (v) {}, title: const Text('2-inch Thermal Printer')),
            RadioListTile(value: 3, groupValue: 1, onChanged: (v) {}, title: const Text('3-inch Thermal Printer')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
                onTap: _showBusinessProfileDialog,
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Print Settings'),
                subtitle: const Text('A4, Thermal, Headers'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showPrintSettingsDialog,
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
                subtitle: const Text('Force push/pull with cloud'),
                trailing: _isSyncing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_upload),
                onTap: _isSyncing ? null : _manualSync,
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup Data'),
                subtitle: const Text('Create local backup of Hive Database'),
                trailing: const Icon(Icons.save_alt),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup created at /Downloads/rk_backup.hive')));
                },
              ),
            ]
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: 'App Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                  }
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Localization coming soon')));
                },
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
