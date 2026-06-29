import 'package:hive/hive.dart';

part 'print_settings_model.g.dart';

@HiveType(typeId: 20) // using 20 to avoid conflicts with other models
class PrintSettingsModel extends HiveObject {
  @HiveField(0)
  String shopName;

  @HiveField(1)
  String shopAddress;

  @HiveField(2)
  String shopMobile;

  @HiveField(3)
  String shopEmail;

  @HiveField(4)
  String gstin;

  @HiveField(5)
  int templateId;

  @HiveField(6)
  String paperSize;

  @HiveField(7)
  List<String> customBlocksOrder;

  PrintSettingsModel({
    this.shopName = 'RK ENTERPRISES',
    this.shopAddress = '123 Main Street, City',
    this.shopMobile = '9876543210',
    this.shopEmail = 'contact@rk.com',
    this.gstin = '',
    this.templateId = 0,
    this.paperSize = 'A4',
    this.customBlocksOrder = const [
      'header',
      'customer',
      'items',
      'totals',
      'footer',
    ],
  });
}
