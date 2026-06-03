import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final netWorthDataProvider = FutureProvider<Map<String, double>>((ref) async {
  final assets = await ref.read(assetRepositoryProvider).getTotalValue();
  final liabilities = await ref.read(liabilityRepositoryProvider).getTotalOutstanding();
  return {'assets': assets, 'liabilities': liabilities, 'netWorth': FinancialCalculator.calculateNetWorth(assets, liabilities)};
});

class NetWorthScreen extends ConsumerWidget {
  const NetWorthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(netWorthDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Net Worth Tracker')),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Card(
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [Colors.indigo[700]!, Colors.indigo[400]!]),
                ),
                child: Column(children: [
                  const Text('Net Worth', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('\$${data['netWorth']!.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Column(children: [const Text('Assets', style: TextStyle(color: Colors.white70)), Text('\$${data['assets']!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                    Column(children: [const Text('Liabilities', style: TextStyle(color: Colors.white70)), Text('\$${data['liabilities']!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                  ]),
                ]),
              ),
            ).animate().slideY(begin: -0.1, duration: 500.ms),
            const SizedBox(height: 24),
            Text('Asset vs Liability', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: data['assets']!, title: 'Assets', color: Colors.green, radius: 90.0, titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: data['liabilities']!, title: 'Liabilities', color: Colors.red, radius: 90.0, titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                  sectionsSpace: 2, centerSpaceRadius: 40,
                ),
              ),
            ).animate().scale(duration: 500.ms),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Assets', style: theme.textTheme.bodyLarge),
                    Text('\$${data['assets']!.toStringAsFixed(2)}', style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold)),
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Liabilities', style: theme.textTheme.bodyLarge),
                    Text('\$${data['liabilities']!.toStringAsFixed(2)}', style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold)),
                  ]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Net Worth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('\$${data['netWorth']!.toStringAsFixed(2)}', style: TextStyle(color: data['netWorth']! >= 0 ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ]),
              ),
            ).animate().slideY(begin: 0.1, duration: 500.ms),
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
