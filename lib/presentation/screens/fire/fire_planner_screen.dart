import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final firePlannerProvider = FutureProvider<Map<String, double>>((ref) async {
  final now = DateTime.now();
  final monthlyExpenses = await ref.read(expenseRepositoryProvider).getTotalByMonth(DateTime(now.year, now.month));
  final annualExpenses = monthlyExpenses * 12;
  final investments = await ref.read(investmentRepositoryProvider).getTotalValue();
  return {'annualExpenses': annualExpenses, 'investments': investments};
});

class FIREPlannerScreen extends ConsumerWidget {
  const FIREPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(firePlannerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('FIRE Planner')),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            ...AppConstants.fireTypes.map((fireType) => _buildFireCard(context, fireType, data)).toList(),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildFireCard(BuildContext context, String fireType, Map<String, double> data) {
    final multiplier = AppConstants.fireMultipliers[fireType] ?? 1.0;
    final annualExpenses = data['annualExpenses']!;
    final adjustedExpenses = annualExpenses * multiplier;
    final fiNumber = FinancialCalculator.calculateFI(adjustedExpenses, 0.04);
    final investments = data['investments']!;
    final progress = FinancialCalculator.calculateFIProgress(investments, fiNumber);
    final years = FinancialCalculator.calculateYearsToFI(investments, annualExpenses * 0.3, fiNumber, 7);
    final monthlyNeeded = FinancialCalculator.calculateMonthlyInvestmentNeeded(fiNumber, investments, 10, 7).clamp(0, double.infinity);

    final colors = {
      'Lean FIRE': Colors.teal, 'Regular FIRE': Colors.blue, 'Fat FIRE': Colors.amber,
    };
    final color = colors[fireType] ?? Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Row(children: [
            Icon(Icons.local_fire_department, color: color),
            const SizedBox(width: 8),
            Text(fireType, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 16),
          Text('\$${fiNumber.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          const Text('FI Number', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (progress / 100).clamp(0, 1), minHeight: 10, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color))),
          const SizedBox(height: 8),
          Text('${progress.toStringAsFixed(1)}% Complete', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildStat('Years to FI', years.isFinite ? '${years.toStringAsFixed(1)}y' : '--', Colors.grey[600]!),
            _buildStat('Monthly Need', '\$${monthlyNeeded.toStringAsFixed(0)}', Colors.grey[600]!),
          ]),
        ]),
      ),
    ).animate().slideY(begin: 0.1, duration: 500.ms);
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }
}
