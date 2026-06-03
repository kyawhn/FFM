import 'package:financial_freedom_management/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAll();
  Future<List<Budget>> getByMonth(DateTime month);
  Future<Map<String, double>> getPlannedVsActual(DateTime month);
  Future<Budget?> getById(String id);
  Future<void> add(Budget budget);
  Future<void> update(Budget budget);
  Future<void> delete(String id);
  Future<void> clearAll();
}
