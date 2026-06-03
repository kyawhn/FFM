import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/expense.dart';

class ExpenseModel {
  static const String boxName = 'expenses';

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      notes: expense.notes,
      createdAt: expense.createdAt,
    );
  }

  Expense toEntity() {
    return Expense(
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

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    category: json['category'],
    date: DateTime.parse(json['date']),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  static String encode(List<ExpenseModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());

  static List<ExpenseModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => ExpenseModel.fromJson(e)).toList();
}
