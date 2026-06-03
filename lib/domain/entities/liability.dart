import 'package:equatable/equatable.dart';

class Liability extends Equatable {
  final String id;
  final String name;
  final String type;
  final double outstandingBalance;
  final double interestRate;
  final DateTime dueDate;
  final String notes;
  final DateTime createdAt;

  const Liability({
    required this.id,
    required this.name,
    required this.type,
    required this.outstandingBalance,
    required this.interestRate,
    required this.dueDate,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Liability copyWith({
    String? id,
    String? name,
    String? type,
    double? outstandingBalance,
    double? interestRate,
    DateTime? dueDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Liability(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      interestRate: interestRate ?? this.interestRate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, type, outstandingBalance, interestRate, dueDate, notes, createdAt];
}
