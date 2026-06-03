import 'dart:ui';
import 'package:equatable/equatable.dart';

class FinancialScore extends Equatable {
  final double totalScore;
  final double savingsRateScore;
  final double debtRatioScore;
  final double emergencyFundScore;
  final double investmentRateScore;
  final double netWorthGrowthScore;

  const FinancialScore({
    required this.totalScore,
    required this.savingsRateScore,
    required this.debtRatioScore,
    required this.emergencyFundScore,
    required this.investmentRateScore,
    required this.netWorthGrowthScore,
  });

  String get rating {
    if (totalScore >= 80) return 'Excellent';
    if (totalScore >= 60) return 'Good';
    if (totalScore >= 40) return 'Fair';
    if (totalScore >= 20) return 'Poor';
    return 'Critical';
  }

  Color get ratingColor {
    if (totalScore >= 80) return const Color(0xFF00C853);
    if (totalScore >= 60) return const Color(0xFF69F0AE);
    if (totalScore >= 40) return const Color(0xFFFFAB00);
    if (totalScore >= 20) return const Color(0xFFFF6D00);
    return const Color(0xFFFF1744);
  }

  @override
  List<Object?> get props => [
    totalScore, savingsRateScore, debtRatioScore,
    emergencyFundScore, investmentRateScore, netWorthGrowthScore
  ];
}
