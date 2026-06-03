import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';
import 'package:financial_freedom_management/domain/entities/financial_score.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final scoreProvider = FutureProvider<FinancialScoreData>((ref) async {
  final now = DateTime.now();
  final thisMonth = DateTime(now.year, now.month);
  final income = await ref.read(incomeRepositoryProvider).getTotalByMonth(thisMonth);
  final expenses = await ref.read(expenseRepositoryProvider).getTotalByMonth(thisMonth);
  final assets = await ref.read(assetRepositoryProvider).getTotalValue();
  final liabilities = await ref.read(liabilityRepositoryProvider).getTotalOutstanding();
  final investments = await ref.read(investmentRepositoryProvider).getTotalValue();
  final goals = await ref.read(goalRepositoryProvider).getAll();

  final savingsRate = FinancialCalculator.calculateSavingsRate(income, expenses);
  final debtRatio = FinancialCalculator.calculateDebtRatio(liabilities, assets);
  final emergencyFund = goals.where((g) => g.type == 'Emergency Fund').fold(0.0, (s, g) => s + g.currentAmount);
  final emergencyMonths = FinancialCalculator.calculateEmergencyFundMonths(expenses, emergencyFund);
  final investmentRate = income > 0 ? (investments / (income * 12)) * 100 : 0.0;
  final score = FinancialCalculator.calculateScore(savingsRate: savingsRate, debtRatio: debtRatio, emergencyFundMonths: emergencyMonths, investmentRate: investmentRate, netWorthGrowth: 5);

  return FinancialScoreData(score: score, savingsRate: savingsRate, debtRatio: debtRatio, emergencyMonths: emergencyMonths, investmentRate: investmentRate);
});

class FinancialScoreData {
  final FinancialScore score;
  final double savingsRate;
  final double debtRatio;
  final double emergencyMonths;
  final double investmentRate;
  FinancialScoreData({required this.score, required this.savingsRate, required this.debtRatio, required this.emergencyMonths, required this.investmentRate});
}

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(scoreProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Freedom Score')),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Card(
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                child: Column(children: [
                  const Text('Your Score', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 180, height: 180,
                    child: Stack(alignment: Alignment.center, children: [
                      PieChart(PieChartData(
                        sections: [
                          PieChartSectionData(value: data.score.totalScore, color: data.score.ratingColor, radius: 90),
                          PieChartSectionData(value: 100 - data.score.totalScore, color: Colors.grey[200]!, radius: 90),
                        ],
                        sectionsSpace: 0, centerSpaceRadius: 60,
                      )),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${data.score.totalScore.toStringAsFixed(0)}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: data.score.ratingColor)),
                        Text(data.score.rating, style: TextStyle(color: data.score.ratingColor, fontWeight: FontWeight.w600)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ).animate().scale(duration: 600.ms),
            const SizedBox(height: 16),
            _buildScoreBar('Savings Rate', data.score.savingsRateScore, data.savingsRate, Icons.savings),
            _buildScoreBar('Debt Ratio', data.score.debtRatioScore, data.debtRatio, Icons.balance),
            _buildScoreBar('Emergency Fund', data.score.emergencyFundScore, data.emergencyMonths, Icons.shield),
            _buildScoreBar('Investment Rate', data.score.investmentRateScore, data.investmentRate, Icons.trending_up),
            _buildScoreBar('Net Worth Growth', data.score.netWorthGrowthScore, 5, Icons.show_chart),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, double value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(icon, color: _scoreColor(score), size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: score / 100, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(score)))),
          ])),
          const SizedBox(width: 12),
          Text('${score.toStringAsFixed(0)}%', style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.bold)),
        ]),
      ),
    ).animate().slideX(begin: 0.1, duration: 400.ms);
  }

  Color _scoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }
}
