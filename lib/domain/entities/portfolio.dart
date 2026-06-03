import 'package:equatable/equatable.dart';

class PortfolioSummary extends Equatable {
  final double totalValue;
  final double totalCostBasis;
  final double totalGainLoss;
  final double totalGainLossPercent;
  final Map<String, double> allocation;

  const PortfolioSummary({
    required this.totalValue,
    required this.totalCostBasis,
    required this.totalGainLoss,
    required this.totalGainLossPercent,
    required this.allocation,
  });

  @override
  List<Object?> get props => [totalValue, totalCostBasis, totalGainLoss, totalGainLossPercent, allocation];
}
