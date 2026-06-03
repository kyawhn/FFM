import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final fiDataProvider = FutureProvider<Map<String, double>>((ref) async {
  final now = DateTime.now();
  final monthlyExpenses = await ref.read(expenseRepositoryProvider).getTotalByMonth(DateTime(now.year, now.month));
  final annualExpenses = monthlyExpenses * 12;
  final investmentValue = await ref.read(investmentRepositoryProvider).getTotalValue();
  final fiNumber = FinancialCalculator.calculateFI(annualExpenses, 0.04);
  final progress = FinancialCalculator.calculateFIProgress(investmentValue, fiNumber);
  return {'annualExpenses': annualExpenses, 'monthlyExpenses': monthlyExpenses, 'investmentValue': investmentValue, 'fiNumber': fiNumber, 'progress': progress};
});

class FICalculatorScreen extends ConsumerWidget {
  const FICalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(fiDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FI Calculator')),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Card(
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [Colors.purple[700]!, Colors.purple[400]!]),
                ),
                child: Column(children: [
                  const Text('FI Number', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('\$${data['fiNumber']!.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Withdrawal Rate: 4%', style: const TextStyle(color: Colors.white70)),
                ]),
              ),
            ).animate().slideY(begin: -0.1, duration: 500.ms),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Current Investments'),
                    Text('\$${data['investmentValue']!.toStringAsFixed(2)}', style: TextStyle(color: Colors.purple[600], fontWeight: FontWeight.bold)),
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Annual Expenses'),
                    Text('\$${data['annualExpenses']!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Monthly Expenses'),
                    Text('\$${data['monthlyExpenses']!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
            ).animate().slideX(begin: 0.1, duration: 500.ms),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const Text('Progress to FI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200, height: 200,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 200, height: 200,
                        child: PieChart(PieChartData(
                          sections: [
                            PieChartSectionData(value: data['progress']!.clamp(0, 100), title: '', color: Colors.purple, radius: 100),
                            PieChartSectionData(value: (100 - data['progress']!.clamp(0, 100)).clamp(0, 100), title: '', color: Colors.grey[200]!, radius: 100),
                          ],
                          sectionsSpace: 0, centerSpaceRadius: 60,
                        )),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${data['progress']!.toStringAsFixed(1)}%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple[700])),
                        const Text('Complete', style: TextStyle(fontSize: 12)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ).animate().scale(duration: 600.ms),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
