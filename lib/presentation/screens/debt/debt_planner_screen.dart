import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/debt_plan.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

final debtPlansProvider = StateNotifierProvider<DebtPlansNotifier, List<DebtPlan>>((ref) => DebtPlansNotifier());

class DebtPlansNotifier extends StateNotifier<List<DebtPlan>> {
  DebtPlansNotifier() : super([]) { _load(); }
  late Box<String> _box;

  Future<void> _load() async {
    _box = await Hive.openBox<String>('debt_plans');
    final data = _box.get('plans');
    if (data != null) {
      try {
        final list = (jsonDecode(data) as List).map((e) => DebtPlan(
          id: e['id'], name: e['name'],
          totalDebt: (e['totalDebt'] as num).toDouble(),
          monthlyPayment: (e['monthlyPayment'] as num).toDouble(),
          interestRate: (e['interestRate'] as num).toDouble(),
          method: e['method'], startDate: DateTime.parse(e['startDate']),
        )).toList();
        state = list;
      } catch (_) {}
    }
  }

  Future<void> add(DebtPlan plan) async {
    state = [...state, plan];
    await _save();
  }

  Future<void> delete(String id) async {
    state = state.where((p) => p.id != id).toList();
    await _save();
  }

  Future<void> _save() async {
    final data = state.map((p) => {
      'id': p.id, 'name': p.name, 'totalDebt': p.totalDebt,
      'monthlyPayment': p.monthlyPayment, 'interestRate': p.interestRate,
      'method': p.method, 'startDate': p.startDate.toIso8601String(),
    }).toList();
    await _box.put('plans', jsonEncode(data));
  }
}

class DebtPlannerScreen extends ConsumerWidget {
  const DebtPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(debtPlansProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Debt Elimination')),
      body: plans.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.credit_card_off, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16), Text('No debt plans', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, i) => _buildPlanCard(context, ref, plans[i]).animate().slideY(begin: 0.1, duration: (300 + i * 50).ms),
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, DebtPlan plan) {
    final color = plan.method == 'Snowball' ? Colors.blue : Colors.green;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(plan.method == 'Snowball' ? Icons.ac_unit : Icons.avalanche, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(plan.method, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildStat('Total Debt', '\$${plan.totalDebt.toStringAsFixed(0)}'),
            _buildStat('Monthly', '\$${plan.monthlyPayment.toStringAsFixed(0)}'),
            _buildStat('Interest', '${plan.interestRate.toStringAsFixed(1)}%'),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildStat('Payoff Date', plan.payoffDate == plan.startDate ? 'N/A' : '${plan.payoffDate.month}/${plan.payoffDate.year}'),
            _buildStat('Interest Saved', plan.totalInterest.isFinite ? '\$${plan.totalInterest.toStringAsFixed(0)}' : 'N/A'),
          ]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Delete'),
              onPressed: () => ref.read(debtPlansProvider.notifier).delete(plan.id),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]);
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final debtCtrl = TextEditingController();
    final paymentCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    String method = AppConstants.debtMethods.first;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: const Text('Add Debt Plan'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Debt Name')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: method, decoration: const InputDecoration(labelText: 'Method'), items: AppConstants.debtMethods.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => method = v!)),
        const SizedBox(height: 8),
        TextField(controller: debtCtrl, decoration: const InputDecoration(labelText: 'Total Debt', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: paymentCtrl, decoration: const InputDecoration(labelText: 'Monthly Payment', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Interest Rate %', suffixText: '%'), keyboardType: TextInputType.number),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final n = nameCtrl.text.trim(); if (n.isEmpty) return;
          final d = double.tryParse(debtCtrl.text); if (d == null || d <= 0) return;
          final p = double.tryParse(paymentCtrl.text); if (p == null || p <= 0) return;
          final r = double.tryParse(rateCtrl.text) ?? 0;
          ref.read(debtPlansProvider.notifier).add(DebtPlan(id: const Uuid().v4(), name: n, totalDebt: d, monthlyPayment: p, interestRate: r, method: method, startDate: DateTime.now()));
          Navigator.pop(ctx);
        }, child: const Text('Add')),
      ],
    )));
  }
}
