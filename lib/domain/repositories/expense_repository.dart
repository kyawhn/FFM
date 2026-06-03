import 'package:financial_freedom_management/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getAll();
  Future<List<Expense>> getByMonth(DateTime month);
  Future<double> getTotalByMonth(DateTime month);
  Future<double> getTotalByYear(int year);
  Future<Map<String, double>> getCategoryTotals(DateTime month);
  Future<Expense?> getById(String id);
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(String id);
  Future<void> clearAll();
}
