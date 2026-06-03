import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/liability.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final liabilityListProvider = FutureProvider<List<Liability>>((ref) async => ref.read(liabilityRepositoryProvider).getAll());
final liabilityTotalProvider = FutureProvider<double>((ref) async => ref.read(liabilityRepositoryProvider).getTotalOutstanding());

class LiabilityScreen extends ConsumerWidget {
  const LiabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liabilitiesAsync = ref.watch(liabilityListProvider);
    final totalAsync = ref.watch(liabilityTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Liability Manager')),
      body: Column(children: [
        totalAsync.when(data: (total) => Container(
          margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red[800]!, Colors.red[600]!]), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.warning, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Liabilities', style: TextStyle(color: Colors.white70)),
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ), loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink()),
        Expanded(child: liabilitiesAsync.when(
          data: (items) => items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.credit_card, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), Text('No liabilities', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey))]))
              : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, itemBuilder: (context, i) => _buildCard(context, ref, items[i]).animate().slideX(begin: 0.1, duration: (300 + i * 50).ms)),
          loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('Error: $e')),
        )),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Liability liability) {
    return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.credit_card, color: Colors.red, size: 20)),
      title: Text(liability.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${liability.type} | ${liability.interestRate.toStringAsFixed(1)}% APR', style: const TextStyle(fontSize: 12)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('\$${liability.outstandingBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        Text('Due: ${liability.dueDate.day}/${liability.dueDate.month}/${liability.dueDate.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
      onTap: () => _showEditDialog(context, ref, liability),
    ));
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final r = await _showForm(context, null);
    if (r != null) {
      await ref.read(liabilityRepositoryProvider).add(Liability(id: const Uuid().v4(), name: r['name'], type: r['type'], outstandingBalance: r['balance'], interestRate: r['rate'], dueDate: r['dueDate'], notes: r['notes']));
      ref.invalidate(liabilityListProvider); ref.invalidate(liabilityTotalProvider); ref.invalidate(dashboardProvider);
    }
  }
  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, Liability item) async {
    final r = await _showForm(context, item);
    if (r != null) {
      await ref.read(liabilityRepositoryProvider).update(item.copyWith(name: r['name'], type: r['type'], outstandingBalance: r['balance'], interestRate: r['rate'], dueDate: r['dueDate'], notes: r['notes']));
      ref.invalidate(liabilityListProvider); ref.invalidate(liabilityTotalProvider); ref.invalidate(dashboardProvider);
    }
  }

  Future<Map<String, dynamic>?> _showForm(BuildContext context, Liability? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final balanceCtrl = TextEditingController(text: existing?.outstandingBalance.toString() ?? '');
    final rateCtrl = TextEditingController(text: existing?.interestRate.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type ?? AppConstants.liabilityTypes.first;
    DateTime dueDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 30));

    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: Text(existing == null ? 'Add Liability' : 'Edit Liability'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Type'), items: AppConstants.liabilityTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => type = v!)),
        const SizedBox(height: 8),
        TextField(controller: balanceCtrl, decoration: const InputDecoration(labelText: 'Outstanding Balance', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Interest Rate %', suffixText: '%'), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Due Date'), readOnly: true, controller: TextEditingController(text: '${dueDate.day}/${dueDate.month}/${dueDate.year}'), onTap: () async { final p = await showDatePicker(context: ctx, initialDate: dueDate, firstDate: DateTime(2020), lastDate: DateTime(2050)); if (p != null) setState(() => dueDate = p); }),
        const SizedBox(height: 8),
        TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        if (existing != null) TextButton(onPressed: () async { await ref.read(liabilityRepositoryProvider).delete(existing.id); ref.invalidate(liabilityListProvider); ref.invalidate(liabilityTotalProvider); ref.invalidate(dashboardProvider); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        FilledButton(onPressed: () { final n = nameCtrl.text.trim(); if (n.isEmpty) return; final b = double.tryParse(balanceCtrl.text); if (b == null || b < 0) return; final r = double.tryParse(rateCtrl.text) ?? 0; Navigator.pop(ctx, {'name': n, 'type': type, 'balance': b, 'rate': r, 'dueDate': dueDate, 'notes': notesCtrl.text}); }, child: Text(existing == null ? 'Add' : 'Update')),
      ],
    )));
  }
}
