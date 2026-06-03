import 'package:equatable/equatable.dart';

class Investment extends Equatable {
  final String id;
  final String name;
  final String type;
  final double costBasis;
  final double currentValue;
  final double quantity;
  final DateTime purchaseDate;
  final String notes;
  final DateTime createdAt;

  Investment({
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

  double get gainLoss => currentValue - (costBasis * quantity);
  double get gainLossPercent => costBasis > 0 ? (gainLoss / (costBasis * quantity)) * 100 : 0;

  @override
  List<Object?> get props => [id, name, type, costBasis, currentValue, quantity, purchaseDate, notes, createdAt];
}
