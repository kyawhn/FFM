import 'dart:convert';
import 'package:financial_freedom_management/domain/entities/savings_goal.dart';

class GoalModel {
  static const String boxName = 'goals';

  final String id;
  final String name;
  final String type;
  final double goalAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String notes;
  final DateTime createdAt;

  GoalModel({
    required this.id, required this.name, required this.type,
    required this.goalAmount, required this.currentAmount,
    required this.targetDate, this.notes = '', DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory GoalModel.fromEntity(SavingsGoal goal) => GoalModel(
    id: goal.id, name: goal.name, type: goal.type,
    goalAmount: goal.goalAmount, currentAmount: goal.currentAmount,
    targetDate: goal.targetDate, notes: goal.notes, createdAt: goal.createdAt,
  );

  SavingsGoal toEntity() => SavingsGoal(
    id: id, name: name, type: type,
    goalAmount: goalAmount, currentAmount: currentAmount,
    targetDate: targetDate, notes: notes, createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'type': type,
    'goalAmount': goalAmount, 'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'notes': notes, 'createdAt': createdAt.toIso8601String(),
  };

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json['id'], name: json['name'], type: json['type'],
    goalAmount: (json['goalAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    targetDate: DateTime.parse(json['targetDate']),
    notes: json['notes'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );

  static String encode(List<GoalModel> models) =>
      jsonEncode(models.map((m) => m.toJson()).toList());
  static List<GoalModel> decode(String data) =>
      (jsonDecode(data) as List).map((e) => GoalModel.fromJson(e)).toList();
}
