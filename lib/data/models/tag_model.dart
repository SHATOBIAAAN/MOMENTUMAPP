import 'package:isar/isar.dart';
import '../../domain/entities/tag.dart';

part 'tag_model.g.dart';

/// Tag Model for Isar Database
@collection
class TagModel {
  Id id = Isar.autoIncrement;

  late String name;

  late String colorHex;

  late DateTime createdAt;

  late int usageCount;

  /// Default constructor required by Isar
  TagModel();

  /// Constructor from domain entity
  TagModel.fromEntity(Tag tag) {
    id = tag.id;
    name = tag.name;
    colorHex = tag.colorHex;
    createdAt = tag.createdAt;
    usageCount = tag.usageCount;
  }


  /// Convert model to domain entity
  Tag toEntity() {
    return Tag(
      id: id,
      name: name,
      colorHex: colorHex,
      createdAt: createdAt,
      usageCount: usageCount,
    );
  }

  /// Create a new tag model for insertion
  factory TagModel.create({
    required String name,
    required String colorHex,
  }) {
    return TagModel()
      ..name = name
      ..colorHex = colorHex
      ..createdAt = DateTime.now()
      ..usageCount = 0;
  }

  /// Copy with method for updates
  TagModel copyWith({
    int? id,
    String? name,
    String? colorHex,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return TagModel()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..colorHex = colorHex ?? this.colorHex
      ..createdAt = createdAt ?? this.createdAt
      ..usageCount = usageCount ?? this.usageCount;
  }
}
