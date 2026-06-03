import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String category;
  final double plannedAmount;
  final double actualAmount;
  final DateTime month;
  final String notes;

  const Budget({
    required this.id,
    required this.category,
    required this.plannedAmount,
    required this.actualAmount,
    required this.month,
    this.notes = '',
  });

  double get variance => plannedAmount - actualAmount;
  double get variancePercent => plannedAmount > 0 ? (variance / plannedAmount) * 100 : 0;

  Budget copyWith({
    String? id,
    String? category,
    double? plannedAmount,
    double? actualAmount,
    DateTime? month,
    String? notes,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      actualAmount: actualAmount ?? this.actualAmount,
      month: month ?? this.month,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, category, plannedAmount, actualAmount, month, notes];
}
