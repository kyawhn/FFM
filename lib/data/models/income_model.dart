import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/income.dart';

class IncomeModel {
  static const String boxName = 'incomes';

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  IncomeModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory IncomeModel.fromEntity(Income income) {
    return IncomeModel(
      id: income.id,
      amount: income.amount,
      category: income.category,
      date: income.date,
      notes: income.notes,
      createdAt: income.createdAt,
    );
  }

  Income toEntity() {
    return Income(
      id: id,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    category: json['category'],
    date: DateTime.parse(json['date']),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  static String encode(List<IncomeModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());

  static List<IncomeModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => IncomeModel.fromJson(e)).toList();
}
