import 'package:financial_freedom_management/domain/entities/liability.dart';

abstract class LiabilityRepository {
  Future<List<Liability>> getAll();
  Future<List<Liability>> getByType(String type);
  Future<double> getTotalOutstanding();
  Future<Map<String, double>> getTypeAllocation();
  Future<Liability?> getById(String id);
  Future<void> add(Liability liability);
  Future<void> update(Liability liability);
  Future<void> delete(String id);
  Future<void> clearAll();
}
