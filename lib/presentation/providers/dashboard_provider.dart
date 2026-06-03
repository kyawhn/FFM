import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';

class DashboardData {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double savingsRate;
  final double fiProgress;
  final double emergencyFundMonths;
  final double debtRatio;
  final double investmentValue;
  final double fiNumber;

  const DashboardData({
    required this.totalAssets, required this.totalLiabilities,
    required this.netWorth, required this.monthlyIncome,
    required this.monthlyExpenses, required this.savingsRate,
    required this.fiProgress, required this.emergencyFundMonths,
    required this.debtRatio, required this.investmentValue,
    required this.fiNumber,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final incomeRepo = ref.read(incomeRepositoryProvider);
  final expenseRepo = ref.read(expenseRepositoryProvider);
  final assetRepo = ref.read(assetRepositoryProvider);
  final liabilityRepo = ref.read(liabilityRepositoryProvider);
  final investmentRepo = ref.read(investmentRepositoryProvider);
  final goalRepo = ref.read(goalRepositoryProvider);

  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month);

  final monthlyIncome = await incomeRepo.getTotalByMonth(thisMonth);
  final monthlyExpenses = await expenseRepo.getTotalByMonth(thisMonth);
  final totalAssets = await assetRepo.getTotalValue();
  final totalLiabilities = await liabilityRepo.getTotalOutstanding();
  final netWorth = FinancialCalculator.calculateNetWorth(totalAssets, totalLiabilities);
  final savingsRate = FinancialCalculator.calculateSavingsRate(monthlyIncome, monthlyExpenses);
  final annualExpenses = monthlyExpenses * 12;
  final fiNumber = FinancialCalculator.calculateFI(annualExpenses, 0.04);
  final investmentValue = await investmentRepo.getTotalValue();
  final fiProgress = FinancialCalculator.calculateFIProgress(investmentValue, fiNumber);
  final goals = await goalRepo.getAll();
  final emergencyFund = goals.where((g) => g.type == 'Emergency Fund')
      .fold(0.0, (sum, g) => sum + g.currentAmount);
  final emergencyFundMonths = FinancialCalculator.calculateEmergencyFundMonths(monthlyExpenses, emergencyFund);
  final debtRatio = FinancialCalculator.calculateDebtRatio(totalLiabilities, totalAssets);

  return DashboardData(
    totalAssets: totalAssets, totalLiabilities: totalLiabilities,
    netWorth: netWorth, monthlyIncome: monthlyIncome,
    monthlyExpenses: monthlyExpenses, savingsRate: savingsRate,
    fiProgress: fiProgress, emergencyFundMonths: emergencyFundMonths,
    debtRatio: debtRatio, investmentValue: investmentValue,
    fiNumber: fiNumber,
  );
});
