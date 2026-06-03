import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/investment.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final investmentListProvider = FutureProvider<List<Investment>>((ref) async => ref.read(investmentRepositoryProvider).getAll());
final investmentSummaryProvider = FutureProvider<Map<String, double>>((ref) async {
  final repo = ref.read(investmentRepositoryProvider);
  return {'totalValue': await repo.getTotalValue(), 'totalCost': await repo.getTotalCostBasis()};
});

class InvestmentScreen extends ConsumerWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(investmentListProvider);
    final summaryAsync = ref.watch(investmentSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Investment Portfolio')),
      body: Column(children: [
        summaryAsync.when(
          data: (s) => Container(
            margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[800]!, Colors.blue[500]!]), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Portfolio Value', style: TextStyle(color: Colors.white70)),
                Text('\$${s['totalValue']!.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                Text('Cost: \$${s['totalCost']!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ]),
            ]),
          ), loading: () => const SizedBox.shrink(), error: (_, __) => const SizedBox.shrink()),
        Expanded(child: listAsync.when(
          data: (items) => items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.pie_chart, size: 80, color: Colors.grey[300]), const SizedBox(height: 16), Text('No investments', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey))]))
              : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, itemBuilder: (context, i) => _buildCard(context, ref, items[i]).animate().slideX(begin: 0.1, duration: (300 + i * 50).ms)),
          loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => Center(child: Text('Error: $e')),
        )),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Investment inv) {
    final isGain = inv.gainLoss >= 0;
    return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (isGain ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(isGain ? Icons.trending_up : Icons.trending_down, color: isGain ? Colors.green : Colors.red, size: 20)),
      title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('${inv.type} | ${inv.quantity.toStringAsFixed(2)} units', style: const TextStyle(fontSize: 12)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('\$${inv.currentValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('${isGain ? '+' : ''}${inv.gainLossPercent.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, color: isGain ? Colors.green : Colors.red)),
      ]),
      onTap: () => _showEditDialog(context, ref, inv),
    ));
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final r = await _showForm(context, ref, null);
    if (r != null) {
      await ref.read(investmentRepositoryProvider).add(Investment(id: const Uuid().v4(), name: r['name'], type: r['type'], costBasis: r['costBasis'], currentValue: r['currentValue'], quantity: r['quantity'], purchaseDate: r['date'], notes: r['notes']));
      ref.invalidate(investmentListProvider); ref.invalidate(investmentSummaryProvider); ref.invalidate(dashboardProvider);
    }
  }
  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, Investment item) async {
    final r = await _showForm(context, ref, item);
    if (r != null) {
      await ref.read(investmentRepositoryProvider).update(Investment(id: item.id, name: r['name'], type: r['type'], costBasis: r['costBasis'], currentValue: r['currentValue'], quantity: r['quantity'], purchaseDate: r['date'], notes: r['notes'], createdAt: item.createdAt));
      ref.invalidate(investmentListProvider); ref.invalidate(investmentSummaryProvider); ref.invalidate(dashboardProvider);
    }
  }

  Future<Map<String, dynamic>?> _showForm(BuildContext context, WidgetRef ref, Investment? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final costCtrl = TextEditingController(text: existing?.costBasis.toString() ?? '');
    final valueCtrl = TextEditingController(text: existing?.currentValue.toString() ?? '');
    final qtyCtrl = TextEditingController(text: existing?.quantity.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type ?? 'Stocks';
    DateTime date = existing?.purchaseDate ?? DateTime.now();

    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: Text(existing == null ? 'Add Investment' : 'Edit Investment'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Type'), items: ['Stocks','ETFs','Mutual Funds','Bonds','Crypto','Real Estate'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => type = v!)),
        const SizedBox(height: 8),
        TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Cost Basis per Unit', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Current Value per Unit', prefixText: '\$ '), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
        const SizedBox(height: 8),
        TextField(decoration: const InputDecoration(labelText: 'Date'), readOnly: true, controller: TextEditingController(text: '${date.day}/${date.month}/${date.year}'), onTap: () async { final p = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setState(() => date = p); }),
        const SizedBox(height: 8),
        TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        if (existing != null) TextButton(onPressed: () async { await ref.read(investmentRepositoryProvider).delete(existing.id); ref.invalidate(investmentListProvider); ref.invalidate(investmentSummaryProvider); ref.invalidate(dashboardProvider); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        FilledButton(onPressed: () { final n = nameCtrl.text.trim(); if (n.isEmpty) return; final c = double.tryParse(costCtrl.text) ?? 0; final v = double.tryParse(valueCtrl.text) ?? 0; final q = double.tryParse(qtyCtrl.text) ?? 1; Navigator.pop(ctx, {'name': n, 'type': type, 'costBasis': c, 'currentValue': v, 'quantity': q, 'date': date, 'notes': notesCtrl.text}); }, child: Text(existing == null ? 'Add' : 'Update')),
      ],
    )));
  }
}
