import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/expense.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final expenseListProvider = FutureProvider<List<Expense>>((ref) async {
  return ref.read(expenseRepositoryProvider).getAll();
});

final monthlyExpenseTotalProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  return ref.read(expenseRepositoryProvider).getTotalByMonth(DateTime(now.year, now.month));
});

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);
    final monthlyTotalAsync = ref.watch(monthlyExpenseTotalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Manager')),
      body: Column(
        children: [
          monthlyTotalAsync.when(
            data: (total) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.orange[700]!, Colors.orange[500]!]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Total', style: TextStyle(color: Colors.white70)),
                      Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: expensesAsync.when(
              data: (expenses) => expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No expenses yet', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return _buildExpenseCard(context, theme, ref, expense).animate().slideX(
                          begin: 0.1, duration: (300 + index * 50).ms);
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ThemeData theme, Expense expense, {VoidCallback? onTap}) {
    final color = _getCategoryColor(expense.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(_getCategoryIcon(expense.category), color: color, size: 20),
        ),
        title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text('${expense.date.day}/${expense.date.month}/${expense.date.year}', style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${expense.amount.toStringAsFixed(2)}', style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold)),
            if (expense.notes.isNotEmpty) Text(expense.notes, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1),
          ],
        ),
        onTap: () => _showEditDialog(context, ref, expense),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    final colors = {
      'Housing': Colors.blue, 'Food': Colors.orange, 'Transportation': Colors.indigo,
      'Healthcare': Colors.red, 'Education': Colors.purple, 'Entertainment': Colors.pink,
      'Debt Payments': Colors.brown, 'Utilities': Colors.teal, 'Insurance': Colors.cyan, 'Miscellaneous': Colors.grey,
    };
    return colors[cat] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String cat) {
    final icons = {
      'Housing': Icons.home, 'Food': Icons.restaurant, 'Transportation': Icons.directions_car,
      'Healthcare': Icons.medical_services, 'Education': Icons.school, 'Entertainment': Icons.movie,
      'Debt Payments': Icons.credit_card, 'Utilities': Icons.electrical_services, 'Insurance': Icons.shield, 'Miscellaneous': Icons.more_horiz,
    };
    return icons[cat] ?? Icons.receipt;
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await _showFormDialog(context, ref, null);
    if (result != null) {
      final expense = Expense(id: const Uuid().v4(), amount: result['amount'], category: result['category'], date: result['date'], notes: result['notes']);
      await ref.read(expenseRepositoryProvider).add(expense);
      ref.invalidate(expenseListProvider);
      ref.invalidate(monthlyExpenseTotalProvider);
      ref.invalidate(dashboardProvider);
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, Expense expense) async {
    final result = await _showFormDialog(context, ref, expense);
    if (result != null) {
      final updated = expense.copyWith(amount: result['amount'], category: result['category'], date: result['date'], notes: result['notes']);
      await ref.read(expenseRepositoryProvider).update(updated);
      ref.invalidate(expenseListProvider);
      ref.invalidate(monthlyExpenseTotalProvider);
      ref.invalidate(dashboardProvider);
    }
  }

  Future<Map<String, dynamic>?> _showFormDialog(BuildContext context, Expense? existing) {
    final amountCtrl = TextEditingController(text: existing?.amount.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String category = existing?.category ?? AppConstants.expenseCategories.first;
    DateTime date = existing?.date ?? DateTime.now();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Expense' : 'Edit Expense'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Date'), readOnly: true,
                controller: TextEditingController(text: '${date.day}/${date.month}/${date.year}'),
                onTap: () async { final p = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030)); if (p != null) setState(() => date = p); },
              ),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            if (existing != null) TextButton(onPressed: () async {
              await ref.read(expenseRepositoryProvider).delete(existing.id);
              ref.invalidate(expenseListProvider);
              ref.invalidate(monthlyExpenseTotalProvider);
              ref.invalidate(dashboardProvider);
              Navigator.pop(ctx);
            }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
            FilledButton(onPressed: () {
              final amt = double.tryParse(amountCtrl.text);
              if (amt == null || amt <= 0) return;
              Navigator.pop(ctx, {'amount': amt, 'category': category, 'date': date, 'notes': notesCtrl.text});
            }, child: Text(existing == null ? 'Add' : 'Update')),
          ],
        ),
      ),
    );
  }
}
