import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/budget.dart';

class BudgetModel {
  static const String boxName = 'budgets';

  final String id;
  final String category;
  final double plannedAmount;
  final double actualAmount;
  final DateTime month;
  final String notes;

  BudgetModel({
    required this.id, required this.category,
    required this.plannedAmount, required this.actualAmount,
    required this.month, this.notes = '',
  });

  factory BudgetModel.fromEntity(Budget budget) => BudgetModel(
    id: budget.id, category: budget.category,
    plannedAmount: budget.plannedAmount, actualAmount: budget.actualAmount,
    month: budget.month, notes: budget.notes,
  );

  Budget toEntity() => Budget(
    id: id, category: category,
    plannedAmount: plannedAmount, actualAmount: actualAmount,
    month: month, notes: notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'category': category,
    'plannedAmount': plannedAmount, 'actualAmount': actualAmount,
    'month': month.toIso8601String(), 'notes': notes,
  };

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    id: json['id'], category: json['category'],
    plannedAmount: (json['plannedAmount'] as num).toDouble(),
    actualAmount: (json['actualAmount'] as num).toDouble(),
    month: DateTime.parse(json['month']),
    notes: json['notes'] ?? '',
  );

  static String encode(List<BudgetModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());
  static List<BudgetModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => BudgetModel.fromJson(e)).toList();
}
