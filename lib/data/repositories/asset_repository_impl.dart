import 'package:financial_freedom_management/data/models/asset_model.dart';
import 'package:financial_freedom_management/domain/entities/asset.dart';
import 'package:financial_freedom_management/domain/repositories/asset_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AssetRepositoryImpl implements AssetRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(AssetModel.boxName);
  }

  @override
  Future<List<Asset>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = AssetModel.decode(data);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Asset>> getByType(String type) async {
    final all = await getAll();
    return all.where((a) => a.type == type).toList();
  }

  @override
  Future<double> getTotalValue() async {
    final all = await getAll();
    return all.fold<double>(0.0, (sum, a) => sum + a.currentValue);
  }

  @override
  Future<double> getTotalPurchaseValue() async {
    final all = await getAll();
    return all.fold<double>(0.0, (sum, a) => sum + a.purchaseValue);
  }

  @override
  Future<Map<String, double>> getTypeAllocation() async {
    final all = await getAll();
    final map = <String, double>{};
    for (final a in all) {
      map[a.type] = (map[a.type] ?? 0) + a.currentValue;
    }
    return map;
  }

  @override
  Future<Asset?> getById(String id) async {
    final all = await getAll();
    return all.where((a) => a.id == id).firstOrNull;
  }

  @override
  Future<void> add(Asset asset) async {
    final all = await getAll();
    all.add(asset);
    await _saveAll(all);
  }

  @override
  Future<void> update(Asset asset) async {
    final all = await getAll();
    final index = all.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      all[index] = asset;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((a) => a.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete('all');
  }

  Future<void> _saveAll(List<Asset> items) async {
    final models = items.map((e) => AssetModel.fromEntity(e)).toList();
    await _box.put('all', AssetModel.encode(models));
  }
}
