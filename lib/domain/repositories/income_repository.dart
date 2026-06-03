import 'package:financial_freedom_management/domain/entities/income.dart';

abstract class IncomeRepository {
  Future<List<Income>> getAll();
  Future<List<Income>> getByMonth(DateTime month);
  Future<double> getTotalByMonth(DateTime month);
  Future<double> getTotalByYear(int year);
  Future<Map<String, double>> getCategoryTotals(DateTime month);
  Future<Income?> getById(String id);
  Future<void> add(Income income);
  Future<void> update(Income income);
  Future<void> delete(String id);
  Future<void> clearAll();
}
