import 'package:financial_freedom_management/data/models/liability_model.dart';
import 'package:financial_freedom_management/domain/entities/liability.dart';
import 'package:financial_freedom_management/domain/repositories/liability_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LiabilityRepositoryImpl implements LiabilityRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(LiabilityModel.boxName);
  }

  @override
  Future<List<Liability>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = LiabilityModel.decode(data);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Liability>> getByType(String type) async {
    final all = await getAll();
    return all.where((l) => l.type == type).toList();
  }

  @override
  Future<double> getTotalOutstanding() async {
    final all = await getAll();
    return all.fold<double>(0.0, (sum, l) => sum + l.outstandingBalance);
  }

  @override
  Future<Map<String, double>> getTypeAllocation() async {
    final all = await getAll();
    final map = <String, double>{};
    for (final l in all) {
      map[l.type] = (map[l.type] ?? 0) + l.outstandingBalance;
    }
    return map;
  }

  @override
  Future<Liability?> getById(String id) async {
    final all = await getAll();
    return all.where((l) => l.id == id).firstOrNull;
  }

  @override
  Future<void> add(Liability liability) async {
    final all = await getAll();
    all.add(liability);
    await _saveAll(all);
  }

  @override
  Future<void> update(Liability liability) async {
    final all = await getAll();
    final index = all.indexWhere((l) => l.id == liability.id);
    if (index != -1) {
      all[index] = liability;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((l) => l.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete('all');
  }

  Future<void> _saveAll(List<Liability> items) async {
    final models = items.map((e) => LiabilityModel.fromEntity(e)).toList();
    await _box.put('all', LiabilityModel.encode(models));
  }
}
