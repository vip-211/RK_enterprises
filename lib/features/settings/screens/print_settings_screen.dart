import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/features/settings/models/print_settings_model.dart';
import 'package:rk_enterprises/features/settings/screens/custom_template_builder_screen.dart';

class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({super.key});

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late Box<PrintSettingsModel> _box;
  late PrintSettingsModel _settings;

  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopMobileController = TextEditingController();
  final _shopEmailController = TextEditingController();
  final _gstinController = TextEditingController();

  final List<String> _paperSizes = ['A4', 'A5', 'Thermal58', 'Thermal80'];
  final List<String> _templates = [
    'A4 Standard (Classic)',
    'A4 Modern',
    'A4 Detailed',
    'A5 Half-Page (Compact)',
    'A5 Half-Page (Modern)',
    'Thermal 58mm (Basic)',
    'Thermal 58mm (Detailed)',
    'Thermal 80mm (Supermarket)',
    'Thermal 80mm (Restaurant)',
    'Custom Drag & Drop',
  ];

  @override
  void initState() {
    super.initState();
    _box = Hive.box<PrintSettingsModel>(HiveBoxes.printSettings);
    if (_box.isEmpty) {
      _settings = PrintSettingsModel();
      _box.put('default', _settings);
    } else {
      _settings = _box.get('default')!;
    }

    _shopNameController.text = _settings.shopName;
    _shopAddressController.text = _settings.shopAddress;
    _shopMobileController.text = _settings.shopMobile;
    _shopEmailController.text = _settings.shopEmail;
    _gstinController.text = _settings.gstin;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _shopMobileController.dispose();
    _shopEmailController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      _settings.shopName = _shopNameController.text.trim();
      _settings.shopAddress = _shopAddressController.text.trim();
      _settings.shopMobile = _shopMobileController.text.trim();
      _settings.shopEmail = _shopEmailController.text.trim();
      _settings.gstin = _gstinController.text.trim();
      _settings.save();
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print Settings Saved')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print & Invoice Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shop Details (Prints on Invoice)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop / Business Name *', prefixIcon: Icon(Icons.store)),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopAddressController,
                decoration: const InputDecoration(labelText: 'Shop Address *', prefixIcon: Icon(Icons.location_on)),
                maxLines: 2,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _shopMobileController,
                      decoration: const InputDecoration(labelText: 'Mobile Number *', prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _shopEmailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _gstinController,
                decoration: const InputDecoration(labelText: 'GSTIN (Optional)', prefixIcon: Icon(Icons.receipt)),
                textCapitalization: TextCapitalization.characters,
              ),
              
              const SizedBox(height: 32),
              const Text('Printing Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _settings.paperSize,
                decoration: const InputDecoration(labelText: 'Default Paper / Printer Size', prefixIcon: Icon(Icons.print)),
                items: _paperSizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  setState(() {
                    _settings.paperSize = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<int>(
                value: _settings.templateId,
                decoration: const InputDecoration(labelText: 'Invoice Template', prefixIcon: Icon(Icons.picture_as_pdf)),
                items: List.generate(_templates.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(_templates[index]),
                  );
                }),
                onChanged: (val) {
                  setState(() {
                    _settings.templateId = val!;
                  });
                },
              ),
              
              if (_settings.templateId == 9) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'You have selected the Custom Drag & Drop template. Configure the blocks before printing.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomTemplateBuilderScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Configure Layout'),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Print Settings', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
