import 'package:equatable/equatable.dart';

class SavingsGoal extends Equatable {
  final String id;
  final String name;
  final String type;
  final double goalAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String notes;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.type,
    required this.goalAmount,
    required this.currentAmount,
    required this.targetDate,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => goalAmount > 0 ? (currentAmount / goalAmount) * 100 : 0;
  double get remaining => goalAmount - currentAmount;

  SavingsGoal copyWith({
    String? id,
    String? name,
    String? type,
    double? goalAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      goalAmount: goalAmount ?? this.goalAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, type, goalAmount, currentAmount, targetDate, notes, createdAt];
}
