import 'package:financial_freedom_management/domain/entities/investment.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> getAll();
  Future<List<Investment>> getByType(String type);
  Future<double> getTotalValue();
  Future<double> getTotalCostBasis();
  Future<Map<String, double>> getTypeAllocation();
  Future<Investment?> getById(String id);
  Future<void> add(Investment investment);
  Future<void> update(Investment investment);
  Future<void> delete(String id);
  Future<void> clearAll();
}
