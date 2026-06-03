import 'package:financial_freedom_management/domain/entities/asset.dart';

abstract class AssetRepository {
  Future<List<Asset>> getAll();
  Future<List<Asset>> getByType(String type);
  Future<double> getTotalValue();
  Future<double> getTotalPurchaseValue();
  Future<Map<String, double>> getTypeAllocation();
  Future<Asset?> getById(String id);
  Future<void> add(Asset asset);
  Future<void> update(Asset asset);
  Future<void> delete(String id);
  Future<void> clearAll();
}
