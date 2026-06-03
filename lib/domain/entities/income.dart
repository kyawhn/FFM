import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String notes;
  final DateTime createdAt;

  const Income({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Income copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, amount, category, date, notes, createdAt];
}
