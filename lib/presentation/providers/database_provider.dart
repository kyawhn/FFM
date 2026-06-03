import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:financial_freedom_management/data/repositories/income_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/expense_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/asset_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/liability_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/investment_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/goal_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/budget_repository_impl.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/domain/repositories/budget_repository.dart';

final initFutureProvider = FutureProvider<void>((ref) async {
  await Hive.initFlutter();
  final incomeRepo = IncomeRepositoryImpl();
  final expenseRepo = ExpenseRepositoryImpl();
  final assetRepo = AssetRepositoryImpl();
  final liabilityRepo = LiabilityRepositoryImpl();
  final investmentRepo = InvestmentRepositoryImpl();
  final goalRepo = GoalRepositoryImpl();
  final budgetRepo = BudgetRepositoryImpl();
  await Future.wait([
    incomeRepo.init(),
    expenseRepo.init(),
    assetRepo.init(),
    liabilityRepo.init(),
    investmentRepo.init(),
    goalRepo.init(),
    budgetRepo.init(),
  ]);
  ref.read(incomeRepositoryProvider.notifier).setRepo(incomeRepo);
  ref.read(expenseRepositoryProvider.notifier).setRepo(expenseRepo);
  ref.read(assetRepositoryProvider.notifier).setRepo(assetRepo);
  ref.read(liabilityRepositoryProvider.notifier).setRepo(liabilityRepo);
  ref.read(investmentRepositoryProvider.notifier).setRepo(investmentRepo);
  ref.read(goalRepositoryProvider.notifier).setRepo(goalRepo);
  ref.read(budgetRepositoryProvider.notifier).setRepo(budgetRepo);
});

class _IncomeRepoNotifier extends Notifier<IncomeRepository> {
  @override
  IncomeRepository build() => throw UnimplementedError('Init first');
  void setRepo(IncomeRepository repo) => state = repo;
}
final incomeRepositoryProvider = NotifierProvider<_IncomeRepoNotifier, IncomeRepository>(_IncomeRepoNotifier.new);

class _ExpenseRepoNotifier extends Notifier<ExpenseRepository> {
  @override
  ExpenseRepository build() => throw UnimplementedError('Init first');
  void setRepo(ExpenseRepository repo) => state = repo;
}
final expenseRepositoryProvider = NotifierProvider<_ExpenseRepoNotifier, ExpenseRepository>(_ExpenseRepoNotifier.new);

class _AssetRepoNotifier extends Notifier<AssetRepository> {
  @override
  AssetRepository build() => throw UnimplementedError('Init first');
  void setRepo(AssetRepository repo) => state = repo;
}
final assetRepositoryProvider = NotifierProvider<_AssetRepoNotifier, AssetRepository>(_AssetRepoNotifier.new);

class _LiabilityRepoNotifier extends Notifier<LiabilityRepository> {
  @override
  LiabilityRepository build() => throw UnimplementedError('Init first');
  void setRepo(LiabilityRepository repo) => state = repo;
}
final liabilityRepositoryProvider = NotifierProvider<_LiabilityRepoNotifier, LiabilityRepository>(_LiabilityRepoNotifier.new);

class _InvestmentRepoNotifier extends Notifier<InvestmentRepository> {
  @override
  InvestmentRepository build() => throw UnimplementedError('Init first');
  void setRepo(InvestmentRepository repo) => state = repo;
}
final investmentRepositoryProvider = NotifierProvider<_InvestmentRepoNotifier, InvestmentRepository>(_InvestmentRepoNotifier.new);

class _GoalRepoNotifier extends Notifier<GoalRepository> {
  @override
  GoalRepository build() => throw UnimplementedError('Init first');
  void setRepo(GoalRepository repo) => state = repo;
}
final goalRepositoryProvider = NotifierProvider<_GoalRepoNotifier, GoalRepository>(_GoalRepoNotifier.new);

class _BudgetRepoNotifier extends Notifier<BudgetRepository> {
  @override
  BudgetRepository build() => throw UnimplementedError('Init first');
  void setRepo(BudgetRepository repo) => state = repo;
}
final budgetRepositoryProvider = NotifierProvider<_BudgetRepoNotifier, BudgetRepository>(_BudgetRepoNotifier.new);
