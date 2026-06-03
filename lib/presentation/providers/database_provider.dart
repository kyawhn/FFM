import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:financial_freedom_management/domain/repositories/budget_repository.dart';

/// These providers are always overridden in main() before runApp().
/// The build() throws because an override replaces it entirely.
final incomeRepositoryProvider = Provider<IncomeRepository>((ref) => throw UnimplementedError('Init first'));
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => throw UnimplementedError('Init first'));
final assetRepositoryProvider = Provider<AssetRepository>((ref) => throw UnimplementedError('Init first'));
final liabilityRepositoryProvider = Provider<LiabilityRepository>((ref) => throw UnimplementedError('Init first'));
final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) => throw UnimplementedError('Init first'));
final goalRepositoryProvider = Provider<GoalRepository>((ref) => throw UnimplementedError('Init first'));
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => throw UnimplementedError('Init first'));
