import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/investment.dart';

class InvestmentModel {
  static const String boxName = 'investments';

  final String id;
  final String name;
  final String type;
  final double costBasis;
  final double currentValue;
  final double quantity;
  final DateTime purchaseDate;
  final String notes;
  final DateTime createdAt;

  InvestmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.costBasis,
    required this.currentValue,
    required this.quantity,
    required this.purchaseDate,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory InvestmentModel.fromEntity(Investment investment) {
    return InvestmentModel(
      id: investment.id,
      name: investment.name,
      type: investment.type,
      costBasis: investment.costBasis,
      currentValue: investment.currentValue,
      quantity: investment.quantity,
      purchaseDate: investment.purchaseDate,
      notes: investment.notes,
      createdAt: investment.createdAt,
    );
  }

  Investment toEntity() {
    return Investment(
      id: id, name: name, type: type,
      costBasis: costBasis, currentValue: currentValue,
      quantity: quantity, purchaseDate: purchaseDate,
      notes: notes, createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type,
    'costBasis': costBasis, 'currentValue': currentValue,
    'quantity': quantity, 'purchaseDate': purchaseDate.toIso8601String(),
    'notes': notes, 'createdAt': createdAt.toIso8601String(),
  };

  factory InvestmentModel.fromJson(Map<String, dynamic> json) => InvestmentModel(
    id: json['id'], name: json['name'], type: json['type'],
    costBasis: (json['costBasis'] as num).toDouble(),
    currentValue: (json['currentValue'] as num).toDouble(),
    quantity: (json['quantity'] as num).toDouble(),
    purchaseDate: DateTime.parse(json['purchaseDate']),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  static String encode(List<InvestmentModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());
  static List<InvestmentModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => InvestmentModel.fromJson(e)).toList();
}
