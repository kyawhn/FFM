import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financial_freedom_management/presentation/providers/theme_provider.dart';
import 'package:financial_freedom_management/core/utils/backup_service.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/domain/repositories/budget_repository.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark/light theme'),
                secondary: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: themeMode == ThemeMode.dark ? Colors.amber : Colors.blue),
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
            ]),
          ).animate().slideY(begin: 0.1, duration: 300.ms),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.backup, color: Colors.green),
                title: const Text('Backup Data'),
                subtitle: const Text('Export all data to JSON'),
                onTap: () async { await _exportBackup(context, ref); },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.orange),
                title: const Text('Restore Data'),
                subtitle: const Text('Import data from JSON backup'),
                onTap: () { /* Import implementation */ },
              ),
            ]),
          ).animate().slideY(begin: 0.1, duration: 400.ms),
          const SizedBox(height: 16),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Data'),
                subtitle: const Text('Remove all financial data'),
                onTap: () => _confirmClearAll(context, ref),
              ),
            ]),
          ).animate().slideY(begin: 0.1, duration: 500.ms),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Financial Freedom Management', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                const Text('Track your path to financial independence', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
          ).animate().slideY(begin: 0.1, duration: 600.ms),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final service = BackupService(
        incomeRepo: ref.read(incomeRepositoryProvider),
        expenseRepo: ref.read(expenseRepositoryProvider),
        assetRepo: ref.read(assetRepositoryProvider),
        liabilityRepo: ref.read(liabilityRepositoryProvider),
        investmentRepo: ref.read(investmentRepositoryProvider),
        goalRepo: ref.read(goalRepositoryProvider),
        budgetRepo: ref.read(budgetRepositoryProvider),
      );
      final file = await service.exportToFile();
      await Share.shareXFiles([XFile(file.path)]);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup exported successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all your financial data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(incomeRepositoryProvider).clearAll();
      await ref.read(expenseRepositoryProvider).clearAll();
      await ref.read(assetRepositoryProvider).clearAll();
      await ref.read(liabilityRepositoryProvider).clearAll();
      await ref.read(investmentRepositoryProvider).clearAll();
      await ref.read(goalRepositoryProvider).clearAll();
      await ref.read(budgetRepositoryProvider).clearAll();
      ref.invalidate(dashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
      }
    }
  }
}
