import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:financial_freedom_management/domain/entities/asset.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/core/constants/app_constants.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

final assetListProvider = FutureProvider<List<Asset>>((ref) async => ref.read(assetRepositoryProvider).getAll());
final assetTotalProvider = FutureProvider<double>((ref) async => ref.read(assetRepositoryProvider).getTotalValue());

class AssetScreen extends ConsumerWidget {
  const AssetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetListProvider);
    final totalAsync = ref.watch(assetTotalProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Asset Manager')),
      body: Column(
        children: [
          totalAsync.when(
            data: (total) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green[800]!, Colors.green[600]!]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                const Icon(Icons.account_balance, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total Assets', style: TextStyle(color: Colors.white70)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: assetsAsync.when(
              data: (assets) => assets.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.work, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No assets yet', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: assets.length,
                      itemBuilder: (context, i) => _buildAssetCard(context, ref, assets[i]).animate().slideX(begin: 0.1, duration: (300 + i * 50).ms),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  Widget _buildAssetCard(BuildContext context, WidgetRef ref, Asset asset) {
    final isGain = asset.currentValue >= asset.purchaseValue;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.account_balance, color: Colors.green, size: 20),
        ),
        title: Text(asset.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(asset.type, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${asset.currentValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${isGain ? '+' : ''}${asset.gainLossPercent.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, color: isGain ? Colors.green : Colors.red)),
          ],
        ),
        onTap: () => _showEditDialog(context, ref, asset),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await _showForm(context, ref, null);
    if (result != null) {
      final a = Asset(id: const Uuid().v4(), name: result['name'], type: result['type'], currentValue: result['currentValue'], purchaseValue: result['purchaseValue'], notes: result['notes']);
      await ref.read(assetRepositoryProvider).add(a);
      ref.invalidate(assetListProvider); ref.invalidate(assetTotalProvider); ref.invalidate(dashboardProvider);
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, Asset asset) async {
    final result = await _showForm(context, ref, asset);
    if (result != null) {
      final a = asset.copyWith(name: result['name'], type: result['type'], currentValue: result['currentValue'], purchaseValue: result['purchaseValue'], notes: result['notes']);
      await ref.read(assetRepositoryProvider).update(a);
      ref.invalidate(assetListProvider); ref.invalidate(assetTotalProvider); ref.invalidate(dashboardProvider);
    }
  }

  Future<Map<String, dynamic>?> _showForm(BuildContext context, WidgetRef ref, Asset? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final currentCtrl = TextEditingController(text: existing?.currentValue.toString() ?? '');
    final purchaseCtrl = TextEditingController(text: existing?.purchaseValue.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String type = existing?.type ?? AppConstants.assetTypes.first;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Asset' : 'Edit Asset'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Asset Name')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Type'), items: AppConstants.assetTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => type = v!)),
            const SizedBox(height: 12),
            TextField(controller: currentCtrl, decoration: const InputDecoration(labelText: 'Current Value', prefixText: '\$ '), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: purchaseCtrl, decoration: const InputDecoration(labelText: 'Purchase Value', prefixText: '\$ '), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 2),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            if (existing != null) TextButton(onPressed: () async {
              await ref.read(assetRepositoryProvider).delete(existing.id);
              ref.invalidate(assetListProvider); ref.invalidate(assetTotalProvider); ref.invalidate(dashboardProvider);
              Navigator.pop(ctx);
            }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
            FilledButton(onPressed: () {
              final name = nameCtrl.text.trim(); if (name.isEmpty) return;
              final curr = double.tryParse(currentCtrl.text); if (curr == null || curr < 0) return;
              final purch = double.tryParse(purchaseCtrl.text) ?? curr;
              Navigator.pop(ctx, {'name': name, 'type': type, 'currentValue': curr, 'purchaseValue': purch, 'notes': notesCtrl.text});
            }, child: Text(existing == null ? 'Add' : 'Update')),
          ],
        ),
      ),
    );
  }
}
