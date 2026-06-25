import 'package:hive/hive.dart';

part 'zikr_model.g.dart';

@HiveType(typeId: 0)
class ZikrModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String transliteration;

  @HiveField(3)
  final String meaning;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  bool isFavorite;

  @HiveField(6)
  int sortOrder;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  DateTime? updatedAt;

  ZikrModel({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.meaning,
    this.isDefault = false,
    this.isFavorite = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ZikrModel copyWith({
    String? id,
    String? name,
    String? transliteration,
    String? meaning,
    bool? isDefault,
    bool? isFavorite,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZikrModel(
      id: id ?? this.id,
      name: name ?? this.name,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      isDefault: isDefault ?? this.isDefault,
      isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get displayName => transliteration.isNotEmpty ? transliteration : name;
}

List<ZikrModel> getDefaultZikrs() {
  return [
    ZikrModel(
      id: 'zikr_subhanallah',
      name: 'سُبْحَانَ ٱللَّٰهِ',
      transliteration: 'SubhanAllah',
      meaning: 'Glory be to Allah',
      isDefault: true,
      sortOrder: 0,
    ),
    ZikrModel(
      id: 'zikr_alhamdulillah',
      name: 'ٱلْحَمْدُ لِلَّٰهِ',
      transliteration: 'Alhamdulillah',
      meaning: 'All praise is due to Allah',
      isDefault: true,
      sortOrder: 1,
    ),
    ZikrModel(
      id: 'zikr_allahuakbar',
      name: 'ٱللَّٰهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      meaning: 'Allah is the Greatest',
      isDefault: true,
      sortOrder: 2,
    ),
    ZikrModel(
      id: 'zikr_astaghfirullah',
      name: 'أَسْتَغْفِرُ ٱللَّٰهَ',
      transliteration: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah',
      isDefault: true,
      sortOrder: 3,
    ),
    ZikrModel(
      id: 'zikr_lailaha',
      name: 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      transliteration: 'La Ilaha Illallah',
      meaning: 'There is no god but Allah',
      isDefault: true,
      sortOrder: 4,
    ),
    ZikrModel(
      id: 'zikr_durood',
      name: 'صَلَّى ٱللَّٰهُ عَلَيْهِ وَسَلَّمَ',
      transliteration: 'Durood Sharif',
      meaning: 'Peace and blessings be upon him',
      isDefault: true,
      sortOrder: 5,
    ),
  ];
}
