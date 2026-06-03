import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/budget.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final budgetListProvider = FutureProvider<List<Budget>>((ref) async => ref.read(budgetRepositoryProvider).getAll());
final budgetComparisonProvider = FutureProvider<Map<String, double>>((ref) async {
  final now = DateTime.now();
  return ref.read(budgetRepositoryProvider).getPlannedVsActual(DateTime(now.year, now.month));
});

class BudgetPlannerScreen extends ConsumerWidget {
  const BudgetPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetListProvider);
    final comparisonAsync = ref.watch(budgetComparisonProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Planner')),
      body: Column(children: [
        comparisonAsync.when(data: (data) => _buildSummary(context, data), loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink()),
        Expanded(child: budgetsAsync.when(
          data: (items) => items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), Text('No budgets', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey))]))
              : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, itemBuilder: (context, i) => _buildBudgetCard(context, ref, items[i]).animate().slideX(begin: 0.1, duration: (300 + i * 50).ms)),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        )),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  Widget _buildSummary(BuildContext context, Map<String, double> variances) {
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo[800]!, Colors.indigo[500]!]), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Text('Budget vs Actual', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        ...variances.entries.take(5).map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 13)),
            Row(children: [
              Icon(e.value >= 0 ? Icons.arrow_downward : Icons.arrow_upward, color: e.value >= 0 ? Colors.green[300] : Colors.red[300], size: 14),
              Text('\$${e.value.abs().toStringAsFixed(0)}', style: TextStyle(color: e.value >= 0 ? Colors.green[300] : Colors.red[300], fontSize: 13)),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _buildBudgetCard(BuildContext context, WidgetRef ref, Budget budget) {
    final isOverBudget = budget.variance < 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(budget.category),
        subtitle: Text('${budget.month.month}/${budget.month.year}'),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Planned: \$${budget.plannedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
          Text('Actual: \$${budget.actualAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: isOverBudget ? Colors.red : Colors.green)),
          Text('${isOverBudget ? 'Over' : 'Under'} \$${budget.variance.abs().toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: isOverBudget ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
        ]),
        onTap: () => _showEditDialog(context, ref, budget),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final r = await _showForm(context, ref, null);
    if (r != null) {
      await ref.read(budgetRepositoryProvider).add(Budget(id: const Uuid().v4(), category: r['category'], plannedAmount: r['planned'], actualAmount: r['actual'], month: r['month'], notes: r['notes']));
      ref.invalidate(budgetListProvider); ref.invalidate(budgetComparisonProvider);
    }
  }
  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, Budget b) async {
    final r = await _showForm(context, ref, b);
    if (r != null) {
      await ref.read(budgetRepositoryProvider).update(b.copyWith(category: r['category'], plannedAmount: r['planned'], actualAmount: r['actual'], month: r['month'], notes: r['notes']));
      ref.invalidate(budgetListProvider); ref.invalidate(budgetComparisonProvider);
    }
  }

  Future<Map<String, dynamic>?> _showForm(BuildContext context, WidgetRef ref, Budget? existing) {
    final plannedCtrl = TextEditingController(text: existing?.plannedAmount.toString() ?? '');
    final actualCtrl = TextEditingController(text: existing?.actualAmount.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String category = existing?.category ?? AppConstants.expenseCategories.first;
    DateTime month = existing?.month ?? DateTime.now();

    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: Text(existing == null ? 'Add Budget' : 'Edit Budget'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Category'), items: AppConstants.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => category = v!)),
        const SizedBox(height: 8),
        TextField(controller: plannedCtrl, decoration: const InputDecoration(labelText: 'Planned Amount', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: actualCtrl, decoration: const InputDecoration(labelText: 'Actual Amount', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Month'), readOnly: true, controller: TextEditingController(text: '${month.month}/${month.year}'), onTap: () async { final p = await showDatePicker(context: ctx, initialDate: month, firstDate: DateTime(2020), lastDate: DateTime(2030)); if (p != null) setState(() => month = DateTime(p.year, p.month)); }),
        const SizedBox(height: 8),
        TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        if (existing != null) TextButton(onPressed: () async { await ref.read(budgetRepositoryProvider).delete(existing.id); ref.invalidate(budgetListProvider); ref.invalidate(budgetComparisonProvider); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        FilledButton(onPressed: () { final p = double.tryParse(plannedCtrl.text) ?? 0; final a = double.tryParse(actualCtrl.text) ?? 0; Navigator.pop(ctx, {'category': category, 'planned': p, 'actual': a, 'month': month, 'notes': notesCtrl.text}); }, child: Text(existing == null ? 'Add' : 'Update')),
      ],
    )));
  }
}
