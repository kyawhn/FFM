import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/asset.dart';

class AssetModel {
  static const String boxName = 'assets';

  final String id;
  final String name;
  final String type;
  final double currentValue;
  final double purchaseValue;
  final String notes;
  final DateTime createdAt;

  AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.currentValue,
    required this.purchaseValue,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AssetModel.fromEntity(Asset asset) {
    return AssetModel(
      id: asset.id,
      name: asset.name,
      type: asset.type,
      currentValue: asset.currentValue,
      purchaseValue: asset.purchaseValue,
      notes: asset.notes,
      createdAt: asset.createdAt,
    );
  }

  Asset toEntity() {
    return Asset(
      id: id,
      name: name,
      type: type,
      currentValue: currentValue,
      purchaseValue: purchaseValue,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'currentValue': currentValue,
    'purchaseValue': purchaseValue,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    currentValue: (json['currentValue'] as num).toDouble(),
    purchaseValue: (json['purchaseValue'] as num).toDouble(),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  static String encode(List<AssetModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());

  static List<AssetModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => AssetModel.fromJson(e)).toList();
}
