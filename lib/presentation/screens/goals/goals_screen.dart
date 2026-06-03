import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/savings_goal.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final goalListProvider = FutureProvider<List<SavingsGoal>>((ref) async => ref.read(goalRepositoryProvider).getAll());

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: goalsAsync.when(
        data: (goals) => goals.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.flag, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No savings goals', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
              ]))
            : ListView.builder(padding: const EdgeInsets.all(16), itemCount: goals.length, itemBuilder: (context, i) => _buildGoalCard(context, ref, goals[i]).animate().slideY(begin: 0.1, duration: (300 + i * 50).ms)),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    final color = _getGoalColor(goal.type);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_getGoalIcon(goal.type), color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            Text('\$${goal.goalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (goal.progress / 100).clamp(0, 1), minHeight: 10, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${goal.progress.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            Text('\$${goal.remaining.toStringAsFixed(0)} remaining', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          if (goal.notes.isNotEmpty) ...[const SizedBox(height: 4), Text(goal.notes, style: const TextStyle(color: Colors.grey, fontSize: 12))],
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(icon: const Icon(Icons.edit, size: 16), onPressed: () => _showEditDialog(context, ref, goal), label: const Text('Edit')),
          ]),
        ]),
      ),
    );
  }

  Color _getGoalColor(String type) {
    final colors = {'Emergency Fund': Colors.red, 'House': Colors.blue, 'Retirement': Colors.purple, 'Business Capital': Colors.green, 'Vacation': Colors.orange, 'Other': Colors.grey};
    return colors[type] ?? Colors.blue;
  }
  IconData _getGoalIcon(String type) {
    final icons = {'Emergency Fund': Icons.shield, 'House': Icons.home, 'Retirement': Icons.beach_access, 'Business Capital': Icons.business, 'Vacation': Icons.flight, 'Other': Icons.flag};
    return icons[type] ?? Icons.flag;
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final r = await _showForm(context, ref, null);
    if (r != null) {
      await ref.read(goalRepositoryProvider).add(SavingsGoal(id: const Uuid().v4(), name: r['name'], type: r['type'], goalAmount: r['goal'], currentAmount: r['current'], targetDate: r['targetDate'], notes: r['notes']));
      ref.invalidate(goalListProvider); ref.invalidate(dashboardProvider);
    }
  }
  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, SavingsGoal g) async {
    final r = await _showForm(context, ref, g);
    if (r != null) {
      await ref.read(goalRepositoryProvider).update(g.copyWith(name: r['name'], type: r['type'], goalAmount: r['goal'], currentAmount: r['current'], targetDate: r['targetDate'], notes: r['notes']));
      ref.invalidate(goalListProvider); ref.invalidate(dashboardProvider);
    }
  }

  Future<Map<String, dynamic>?> _showForm(BuildContext context, WidgetRef ref, SavingsGoal? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final goalCtrl = TextEditingController(text: existing?.goalAmount.toString() ?? '');
    final currentCtrl = TextEditingController(text: existing?.currentAmount.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type ?? AppConstants.goalTypes.first;
    DateTime targetDate = existing?.targetDate ?? DateTime.now().add(const Duration(days: 365));

    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: Text(existing == null ? 'Add Goal' : 'Edit Goal'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Goal Name')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Type'), items: AppConstants.goalTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => type = v!)),
        const SizedBox(height: 8),
        TextField(controller: goalCtrl, decoration: const InputDecoration(labelText: 'Goal Amount', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: currentCtrl, decoration: const InputDecoration(labelText: 'Current Amount', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Target Date'), readOnly: true, controller: TextEditingController(text: '${targetDate.day}/${targetDate.month}/${targetDate.year}'), onTap: () async { final p = await showDatePicker(context: ctx, initialDate: targetDate, firstDate: DateTime.now(), lastDate: DateTime(2050)); if (p != null) setState(() => targetDate = p); }),
        const SizedBox(height: 8),
        TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        if (existing != null) TextButton(onPressed: () async { await ref.read(goalRepositoryProvider).delete(existing.id); ref.invalidate(goalListProvider); ref.invalidate(dashboardProvider); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        FilledButton(onPressed: () { final n = nameCtrl.text.trim(); if (n.isEmpty) return; final g = double.tryParse(goalCtrl.text); if (g == null || g <= 0) return; final c = double.tryParse(currentCtrl.text) ?? 0; Navigator.pop(ctx, {'name': n, 'type': type, 'goal': g, 'current': c, 'targetDate': targetDate, 'notes': notesCtrl.text}); }, child: Text(existing == null ? 'Add' : 'Update')),
      ],
    )));
  }
}
