import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/liability.dart';

class LiabilityModel {
  static const String boxName = 'liabilities';

  final String id;
  final String name;
  final String type;
  final double outstandingBalance;
  final double interestRate;
  final DateTime dueDate;
  final String notes;
  final DateTime createdAt;

  LiabilityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.outstandingBalance,
    required this.interestRate,
    required this.dueDate,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LiabilityModel.fromEntity(Liability liability) {
    return LiabilityModel(
      id: liability.id,
      name: liability.name,
      type: liability.type,
      outstandingBalance: liability.outstandingBalance,
      interestRate: liability.interestRate,
      dueDate: liability.dueDate,
      notes: liability.notes,
      createdAt: liability.createdAt,
    );
  }

  Liability toEntity() {
    return Liability(
      id: id,
      name: name,
      type: type,
      outstandingBalance: outstandingBalance,
      interestRate: interestRate,
      dueDate: dueDate,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type,
    'outstandingBalance': outstandingBalance,
    'interestRate': interestRate,
    'dueDate': dueDate.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LiabilityModel.fromJson(Map<String, dynamic> json) => LiabilityModel(
    id: json['id'], name: json['name'], type: json['type'],
    outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
    interestRate: (json['interestRate'] as num).toDouble(),
    dueDate: DateTime.parse(json['dueDate']),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  static String encode(List<LiabilityModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());
  static List<LiabilityModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => LiabilityModel.fromJson(e)).toList();
}
