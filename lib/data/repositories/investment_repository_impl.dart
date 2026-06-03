import 'package:financial_freedom_management/data/models/investment_model.dart';
import 'package:financial_freedom_management/domain/entities/investment.dart';
import 'package:financial_freedom_management/domain/repositories/investment_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(InvestmentModel.boxName);
  }

  @override
  Future<List<Investment>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = InvestmentModel.decode(data);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Investment>> getByType(String type) async {
    final all = await getAll();
    return all.where((i) => i.type == type).toList();
  }

  @override
  Future<double> getTotalValue() async {
    final all = await getAll();
    return all.fold<double>(0.0, (sum, i) => sum + i.currentValue);
  }

  @override
  Future<double> getTotalCostBasis() async {
    final all = await getAll();
    return all.fold<double>(0.0, (sum, i) => sum + (i.costBasis * i.quantity));
  }

  @override
  Future<Map<String, double>> getTypeAllocation() async {
    final all = await getAll();
    final map = <String, double>{};
    for (final i in all) {
      map[i.type] = (map[i.type] ?? 0) + i.currentValue;
    }
    return map;
  }

  @override
  Future<Investment?> getById(String id) async {
    final all = await getAll();
    return all.where((i) => i.id == id).firstOrNull;
  }

  @override
  Future<void> add(Investment investment) async {
    final all = await getAll();
    all.add(investment);
    await _saveAll(all);
  }

  @override
  Future<void> update(Investment investment) async {
    final all = await getAll();
    final index = all.indexWhere((i) => i.id == investment.id);
    if (index != -1) {
      all[index] = investment;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((i) => i.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete('all');
  }

  Future<void> _saveAll(List<Investment> items) async {
    final models = items.map((e) => InvestmentModel.fromEntity(e)).toList();
    await _box.put('all', InvestmentModel.encode(models));
  }
}
