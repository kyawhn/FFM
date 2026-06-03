import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final healthDataProvider = FutureProvider<Map<String, double>>((ref) async {
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
  final annualExpenses = expenses * 12;
  final fiNumber = FinancialCalculator.calculateFI(annualExpenses, 0.04);
  final fiRatio = FinancialCalculator.calculateFIProgress(investments, fiNumber);
  final emergencyFund = goals.where((g) => g.type == 'Emergency Fund').fold(0.0, (s, g) => s + g.currentAmount);
  final emergencyMonths = FinancialCalculator.calculateEmergencyFundMonths(expenses, emergencyFund);

  return {
    'savingsRate': savingsRate, 'debtRatio': debtRatio, 'fiRatio': fiRatio,
    'emergencyMonths': emergencyMonths, 'totalAssets': assets, 'totalLiabilities': liabilities,
    'income': income, 'expenses': expenses, 'investments': investments,
  };
});

class HealthDashboardScreen extends ConsumerWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(healthDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health')),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _buildHealthGauge(context, data),
            const SizedBox(height: 16),
            _buildHealthCard(context, 'Savings Rate', '${data['savingsRate']!.toStringAsFixed(1)}%', _getHealthColor(data['savingsRate']!, 15, 30), Icons.savings),
            _buildHealthCard(context, 'Debt Ratio', '${data['debtRatio']!.toStringAsFixed(1)}%', _getHealthColor(100 - data['debtRatio']!, 30, 60), Icons.balance),
            _buildHealthCard(context, 'FI Ratio', '${data['fiRatio']!.toStringAsFixed(1)}%', _getHealthColor(data['fiRatio']!, 25, 50), Icons.flag),
            _buildHealthCard(context, 'Emergency Fund', '${data['emergencyMonths']!.toStringAsFixed(1)} months', _getHealthColor(data['emergencyMonths']! * 8.33, 33, 66), Icons.shield),
            _buildHealthCard(context, 'Asset Allocation', _getAllocationDesc(data), Colors.blue, Icons.pie_chart),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHealthGauge(BuildContext context, Map<String, double> data) {
    final sr = (data['savingsRate']! / 50).clamp(0, 1).toDouble();
    final dr = (1 - data['debtRatio']! / 100).clamp(0, 1).toDouble();
    final fir = (data['fiRatio']! / 100).clamp(0, 1).toDouble();
    final ef = (data['emergencyMonths']! / 12).clamp(0, 1).toDouble();
    final health = (sr * 0.3 + dr * 0.25 + fir * 0.25 + ef * 0.2) * 100;

    return Card(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Text('Overall Financial Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        SizedBox(
          width: 150, height: 150,
          child: Stack(alignment: Alignment.center, children: [
            PieChart(PieChartData(
              sections: [PieChartSectionData(value: health, color: _healthColor(health), radius: 75), PieChartSectionData(value: (100.0 - health).toDouble(), color: Colors.grey[200]!, radius: 75)],
              sectionsSpace: 0, centerSpaceRadius: 50.0,
            )),
            Column(children: [
              Text('${health.toStringAsFixed(0)}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _healthColor(health))),
              const Text('Health', style: TextStyle(fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    )).animate().scale(duration: 600.ms);
  }

  Widget _buildHealthCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
        title: Text(label),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ),
    ).animate().slideX(begin: 0.1, duration: 400.ms);
  }

  Color _healthColor(double h) {
    if (h >= 70) return Colors.green;
    if (h >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getHealthColor(double value, double min, double good) {
    if (value >= good) return Colors.green;
    if (value >= min) return Colors.orange;
    return Colors.red;
  }

  String _getAllocationDesc(Map<String, double> d) {
    final a = d['totalAssets'] ?? 0;
    final l = d['totalLiabilities'] ?? 0;
    if (a <= 0) return 'No assets';
    return '${((a - l) / a * 100).toStringAsFixed(0)}% equity';
  }
}
