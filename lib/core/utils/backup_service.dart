import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/domain/repositories/budget_repository.dart';

class BackupService {
  final IncomeRepository incomeRepo;
  final ExpenseRepository expenseRepo;
  final AssetRepository assetRepo;
  final LiabilityRepository liabilityRepo;
  final InvestmentRepository investmentRepo;
  final GoalRepository goalRepo;
  final BudgetRepository budgetRepo;

  BackupService({
    required this.incomeRepo,
    required this.expenseRepo,
    required this.assetRepo,
    required this.liabilityRepo,
    required this.investmentRepo,
    required this.goalRepo,
    required this.budgetRepo,
  });

  Future<String> exportBackup() async {
    final backup = {
      'incomes': (await incomeRepo.getAll()).map((e) => {
        'id': e.id, 'amount': e.amount, 'category': e.category,
        'date': e.date.toIso8601String(), 'notes': e.notes,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'expenses': (await expenseRepo.getAll()).map((e) => {
        'id': e.id, 'amount': e.amount, 'category': e.category,
        'date': e.date.toIso8601String(), 'notes': e.notes,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'assets': (await assetRepo.getAll()).map((a) => {
        'id': a.id, 'name': a.name, 'type': a.type,
        'currentValue': a.currentValue, 'purchaseValue': a.purchaseValue,
        'notes': a.notes, 'createdAt': a.createdAt.toIso8601String(),
      }).toList(),
      'liabilities': (await liabilityRepo.getAll()).map((l) => {
        'id': l.id, 'name': l.name, 'type': l.type,
        'outstandingBalance': l.outstandingBalance,
        'interestRate': l.interestRate,
        'dueDate': l.dueDate.toIso8601String(), 'notes': l.notes,
        'createdAt': l.createdAt.toIso8601String(),
      }).toList(),
      'investments': (await investmentRepo.getAll()).map((i) => {
        'id': i.id, 'name': i.name, 'type': i.type,
        'costBasis': i.costBasis, 'currentValue': i.currentValue,
        'quantity': i.quantity,
        'purchaseDate': i.purchaseDate.toIso8601String(),
        'notes': i.notes, 'createdAt': i.createdAt.toIso8601String(),
      }).toList(),
      'goals': (await goalRepo.getAll()).map((g) => {
        'id': g.id, 'name': g.name, 'type': g.type,
        'goalAmount': g.goalAmount, 'currentAmount': g.currentAmount,
        'targetDate': g.targetDate.toIso8601String(),
        'notes': g.notes, 'createdAt': g.createdAt.toIso8601String(),
      }).toList(),
      'budgets': (await budgetRepo.getAll()).map((b) => {
        'id': b.id, 'category': b.category,
        'plannedAmount': b.plannedAmount, 'actualAmount': b.actualAmount,
        'month': b.month.toIso8601String(), 'notes': b.notes,
      }).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  Future<File> exportToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ffm_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    final json = await exportBackup();
    await file.writeAsString(json);
    return file;
  }

  Future<void> importBackup(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    await _importList(data['incomes'], incomeRepo.add);
    await _importList(data['expenses'], expenseRepo.add);
    // Import assets, liabilities etc. using fromJson-like methods
  }

  Future<void> _importList<T>(dynamic list, Future<void> Function(T) add) async {
    // Simplified - in production would use proper deserialization
  }
}
