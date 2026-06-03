import 'package:equatable/equatable.dart';

class Asset extends Equatable {
  final String id;
  final String name;
  final String type;
  final double currentValue;
  final double purchaseValue;
  final String notes;
  final DateTime createdAt;

  Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.currentValue,
    required this.purchaseValue,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Asset copyWith({
    String? id,
    String? name,
    String? type,
    double? currentValue,
    double? purchaseValue,
    String? notes,
    DateTime? createdAt,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get gainLoss => currentValue - purchaseValue;
  double get gainLossPercent => purchaseValue > 0 ? (gainLoss / purchaseValue) * 100 : 0;

  @override
  List<Object?> get props => [id, name, type, currentValue, purchaseValue, notes, createdAt];
}
