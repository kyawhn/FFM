import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/income.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final incomeListProvider = FutureProvider<List<Income>>((ref) async {
  return ref.read(incomeRepositoryProvider).getAll();
});

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(incomeListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Income Manager')),
      body: incomesAsync.when(
        data: (incomes) => incomes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No income entries yet', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Tap + to add your first income', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  return _buildIncomeCard(context, theme, ref, income).animate().slideX(
                    begin: 0.1, duration: (300 + index * 50).ms, delay: (index * 30).ms);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, ThemeData theme, Income income, {VoidCallback? onTap}) {
    final color = _getCategoryColor(income.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(_getCategoryIcon(income.category), color: color),
        ),
        title: Text(income.category, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${income.date.day}/${income.date.month}/${income.date.year}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${income.amount.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold, fontSize: 16)),
            if (income.notes.isNotEmpty) Text(income.notes, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey), maxLines: 1),
          ],
        ),
        onTap: () => _showEditDialog(context, ref, income),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Salary': AppTheme.primaryColor, 'Business': AppTheme.accentColor,
      'Rental': AppTheme.successColor, 'Dividends': AppTheme.warningColor,
      'Interest': Colors.teal, 'Side Hustles': Colors.orange, 'Other': Colors.grey,
    };
    return colors[category] ?? Colors.blue;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Salary': Icons.work, 'Business': Icons.business, 'Rental': Icons.home,
      'Dividends': Icons.trending_up, 'Interest': Icons.monetization_on,
      'Side Hustles': Icons.handyman, 'Other': Icons.more_horiz,
    };
    return icons[category] ?? Icons.attach_money;
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await _showFormDialog(context, null);
    if (result != null) {
      final income = Income(id: const Uuid().v4(), amount: result['amount'], category: result['category'], date: result['date'], notes: result['notes']);
      await ref.read(incomeRepositoryProvider).add(income);
      ref.invalidate(incomeListProvider);
      ref.invalidate(dashboardProvider);
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, Income income) async {
    final result = await _showFormDialog(context, income);
    if (result != null) {
      final updated = income.copyWith(amount: result['amount'], category: result['category'], date: result['date'], notes: result['notes']);
      await ref.read(incomeRepositoryProvider).update(updated);
      ref.invalidate(incomeListProvider);
      ref.invalidate(dashboardProvider);
    }
  }

  Future<Map<String, dynamic>?> _showFormDialog(BuildContext context, Income? existing) {
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String category = existing?.category ?? AppConstants.incomeCategories.first;
    DateTime date = existing?.date ?? DateTime.now();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Income' : 'Edit Income'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.incomeCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  controller: TextEditingController(text: '${date.day}/${date.month}/${date.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (picked != null) setState(() => date = picked);
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            if (existing != null)
              TextButton(onPressed: () async {
                await ref.read(incomeRepositoryProvider).delete(existing.id);
                ref.invalidate(incomeListProvider);
                ref.invalidate(dashboardProvider);
                Navigator.pop(ctx);
              }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
            FilledButton(onPressed: () {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx, {'amount': amount, 'category': category, 'date': date, 'notes': notesCtrl.text});
            }, child: Text(existing == null ? 'Add' : 'Update')),
          ],
        ),
      ),
    );
  }
}
