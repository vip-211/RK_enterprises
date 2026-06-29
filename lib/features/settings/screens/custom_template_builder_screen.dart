import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/settings/models/print_settings_model.dart';

class CustomTemplateBuilderScreen extends StatefulWidget {
  const CustomTemplateBuilderScreen({super.key});

  @override
  State<CustomTemplateBuilderScreen> createState() => _CustomTemplateBuilderScreenState();
}

class _CustomTemplateBuilderScreenState extends State<CustomTemplateBuilderScreen> {
  late Box<PrintSettingsModel> _box;
  late PrintSettingsModel _settings;
  late List<String> _blocks;

  final Map<String, String> _blockNames = {
    'header': 'Shop Header (Name & Contact)',
    'customer': 'Customer Details',
    'items': 'Items Table',
    'totals': 'Totals & Tax Summary',
    'footer': 'Footer Notes (Thank You)',
  };

  final Map<String, IconData> _blockIcons = {
    'header': Icons.store,
    'customer': Icons.person,
    'items': Icons.list_alt,
    'totals': Icons.calculate,
    'footer': Icons.favorite,
  };

  @override
  void initState() {
    super.initState();
    _box = Hive.box<PrintSettingsModel>(HiveBoxes.printSettings);
    _settings = _box.get('default')!;
    // Ensure all 5 blocks exist in the list (in case it's a new settings object)
    _blocks = List.from(_settings.customBlocksOrder);
    for (final key in _blockNames.keys) {
      if (!_blocks.contains(key)) {
        _blocks.add(key);
      }
    }
  }

  void _saveOrder() {
    _settings.customBlocksOrder = _blocks;
    _settings.save();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom Template Layout Saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Drag & Drop Layout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveOrder,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: const Text(
              'Drag the blocks below using the handle on the right to reorder how they appear on your custom invoice.',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.all(16),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _blocks.removeAt(oldIndex);
                  _blocks.insert(newIndex, item);
                });
              },
              children: [
                for (int index = 0; index < _blocks.length; index++)
                  Card(
                    key: ValueKey(_blocks[index]),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(_blockIcons[_blocks[index]], color: Colors.blue),
                      ),
                      title: Text(_blockNames[_blocks[index]]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Block position: ${index + 1}'),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Layout', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
