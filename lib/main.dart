import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:financial_freedom_management/app.dart';
import 'package:financial_freedom_management/data/repositories/income_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/expense_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/asset_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/liability_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/investment_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/goal_repository_impl.dart';
import 'package:financial_freedom_management/data/repositories/budget_repository_impl.dart';
import 'package:financial_freedom_management/presentation/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Initialize all repositories (opens Hive boxes)
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

  runApp(
    ProviderScope(
      overrides: [
        incomeRepositoryProvider.overrideWith((ref) => incomeRepo),
        expenseRepositoryProvider.overrideWith((ref) => expenseRepo),
        assetRepositoryProvider.overrideWith((ref) => assetRepo),
        liabilityRepositoryProvider.overrideWith((ref) => liabilityRepo),
        investmentRepositoryProvider.overrideWith((ref) => investmentRepo),
        goalRepositoryProvider.overrideWith((ref) => goalRepo),
        budgetRepositoryProvider.overrideWith((ref) => budgetRepo),
      ],
      child: const FFMApp(),
    ),
  );
}
