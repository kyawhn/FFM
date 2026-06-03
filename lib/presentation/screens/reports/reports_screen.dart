import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final reportDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final now = DateTime.now();
  final year = now.year;
  final incomeRepo = ref.read(incomeRepositoryProvider);
  final expenseRepo = ref.read(expenseRepositoryProvider);
  final assetRepo = ref.read(assetRepositoryProvider);
  final liabilityRepo = ref.read(liabilityRepositoryProvider);

  Map<String, double> monthlyIncome = {};
  Map<String, double> monthlyExpenses = {};
  for (int m = 1; m <= 12; m++) {
    final month = DateTime(year, m);
    monthlyIncome['${m}'] = await incomeRepo.getTotalByMonth(month);
    monthlyExpenses['${m}'] = await expenseRepo.getTotalByMonth(month);
  }
  final incomeCategories = await incomeRepo.getCategoryTotals(DateTime(year, now.month));
  final expenseCategories = await expenseRepo.getCategoryTotals(DateTime(year, now.month));
  final totalAssets = await assetRepo.getTotalValue();
  final totalLiabilities = await liabilityRepo.getTotalOutstanding();

  return {
    'year': year, 'monthlyIncome': monthlyIncome, 'monthlyExpenses': monthlyExpenses,
    'incomeCategories': incomeCategories, 'expenseCategories': expenseCategories,
    'totalAssets': totalAssets, 'totalLiabilities': totalLiabilities,
  };
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(reportDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _buildSummaryCard('Total Assets', '\$${(data['totalAssets'] as double).toStringAsFixed(0)}', Colors.green, Icons.account_balance)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('Total Liabilities', '\$${(data['totalLiabilities'] as double).toStringAsFixed(0)}', Colors.red, Icons.credit_card)),
            ]),
            const SizedBox(height: 24),
            Text('Income vs Expenses - ${data['year']}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildIncomeExpenseChart(data['monthlyIncome'] as Map<String, double>, data['monthlyExpenses'] as Map<String, double>),
            ).animate().slideY(begin: 0.1, duration: 500.ms),
            const SizedBox(height: 24),
            Text('Expense Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildCategoryPieChart(data['expenseCategories'] as Map<String, double>),
            ).animate().scale(duration: 500.ms),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Export as CSV'),
                onPressed: () => _exportCSV(data['monthlyIncome'] as Map<String, double>, data['monthlyExpenses'] as Map<String, double>),
              ),
            ),
            const SizedBox(height: 80),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    ));
  }

  Widget _buildIncomeExpenseChart(Map<String, double> income, Map<String, double> expenses) {
    final maxVal = [income.values, expenses.values].expand((e) => e).fold(0.0, (a, b) => a > b ? a : b);
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxVal * 1.2,
      barGroups: List.generate(12, (i) {
        final month = '${i + 1}';
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: income[month] ?? 0, color: Colors.green, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          BarChartRodData(toY: expenses[month] ?? 0, color: Colors.red, width: 8, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        ]);
      }),
      titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 4), child: Text(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][v.toInt()], style: const TextStyle(fontSize: 10))))),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('\$${(v/1000).toInt()}k', style: const TextStyle(fontSize: 10)))), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _buildCategoryPieChart(Map<String, double> categories) {
    final colors = [Colors.blue, Colors.orange, Colors.indigo, Colors.red, Colors.purple, Colors.pink, Colors.brown, Colors.teal, Colors.cyan, Colors.grey];
    final total = categories.values.fold(0.0, (a, b) => a + b);
    return PieChart(PieChartData(
      sections: categories.entries.toList().asMap().entries.map((e) => PieChartSectionData(
        value: e.value.value, title: '${(e.value.value / total * 100).toStringAsFixed(0)}%',
        color: colors[e.key % colors.length], radius: 80,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      )).toList(),
      sectionsSpace: 2, centerSpaceRadius: 30,
    ));
  }

  Future<void> _exportCSV(Map<String, double> income, Map<String, double> expenses) async {
    final rows = <List<String>>[['Month', 'Income', 'Expenses', 'Net']];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    for (int i = 0; i < 12; i++) {
      final inc = income['${i+1}'] ?? 0;
      final exp = expenses['${i+1}'] ?? 0;
      rows.add([months[i], inc.toStringAsFixed(2), exp.toStringAsFixed(2), (inc-exp).toStringAsFixed(2)]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ffm_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)]);
  }
}
