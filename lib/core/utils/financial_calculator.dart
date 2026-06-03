import 'dart:math';
import 'package:financial_freedom_management/domain/entities/financial_score.dart';

class FinancialCalculator {
  static double calculateNetWorth(double totalAssets, double totalLiabilities) {
    return totalAssets - totalLiabilities;
  }

  static double calculateSavingsRate(double income, double expenses) {
    if (income <= 0) return 0;
    return ((income - expenses) / income) * 100;
  }

  static double calculateEmergencyFundMonths(double totalExpenses, double emergencyFundAmount) {
    if (totalExpenses <= 0) return 0;
    return emergencyFundAmount / (totalExpenses / 12);
  }

  static double calculateFI(double annualExpenses, double withdrawalRate) {
    if (withdrawalRate <= 0) return double.infinity;
    return annualExpenses / withdrawalRate;
  }

  static double calculateFIProgress(double currentInvestments, double fiNumber) {
    if (fiNumber <= 0) return 0;
    return (currentInvestments / fiNumber) * 100;
  }

  static double calculateDebtRatio(double totalLiabilities, double totalAssets) {
    if (totalAssets <= 0) return 100;
    return (totalLiabilities / totalAssets) * 100;
  }

  static double calculateYearsToFI(double currentInvestments, double annualSavings, double fiNumber, double annualReturn) {
    if (fiNumber <= 0 || fiNumber.isInfinite) return 0;
    if (currentInvestments >= fiNumber) return 0;
    if (annualSavings <= 0) return double.infinity;
    final rate = annualReturn / 100;
    final target = fiNumber - currentInvestments;
    if (rate == 0) return target / annualSavings;
    return log(1 + (target * rate) / annualSavings) / log(1 + rate);
  }

  static double calculateMonthlyInvestmentNeeded(double fiNumber, double currentInvestments, double years, double annualReturn) {
    if (years <= 0) return 0;
    final rate = annualReturn / 12 / 100;
    final months = years * 12;
    final target = fiNumber - currentInvestments;
    if (rate == 0) return target / months;
    return target * rate / (pow(1 + rate, months) - 1);
  }

  static FinancialScore calculateScore({
    required double savingsRate,
    required double debtRatio,
    required double emergencyFundMonths,
    required double investmentRate,
    required double netWorthGrowth,
  }) {
    final savingsRateScore = _normalizeScore(savingsRate, 0, 50, 0, 100);
    final debtRatioScore = (_normalizeScore(100 - debtRatio, 0, 100, 0, 100)).clamp(0, 100).toDouble();
    final emergencyFundScore = _normalizeScore(emergencyFundMonths, 0, 12, 0, 100);
    final investmentRateScore = _normalizeScore(investmentRate, 0, 50, 0, 100);
    final netWorthGrowthScore = (_normalizeScore(netWorthGrowth, -50, 50, 0, 100)).clamp(0, 100).toDouble();

    final totalScore = (savingsRateScore * 0.25 +
        debtRatioScore * 0.20 +
        emergencyFundScore * 0.20 +
        investmentRateScore * 0.20 +
        netWorthGrowthScore * 0.15);

    return FinancialScore(
      totalScore: totalScore.clamp(0, 100).toDouble(),
      savingsRateScore: savingsRateScore.clamp(0, 100).toDouble(),
      debtRatioScore: debtRatioScore.clamp(0, 100).toDouble(),
      emergencyFundScore: emergencyFundScore.clamp(0, 100).toDouble(),
      investmentRateScore: investmentRateScore.clamp(0, 100).toDouble(),
      netWorthGrowthScore: netWorthGrowthScore.clamp(0, 100).toDouble(),
    );
  }

  static double _normalizeScore(double value, double min, double max, double outMin, double outMax) {
    if (value < min) return outMin;
    if (value > max) return outMax;
    return outMin + ((value - min) / (max - min)) * (outMax - outMin);
  }
}
