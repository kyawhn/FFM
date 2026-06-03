import 'package:financial_freedom_management/data/models/budget_model.dart';
import 'package:financial_freedom_management/domain/entities/budget.dart';
import 'package:financial_freedom_management/domain/repositories/budget_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(BudgetModel.boxName);
  }

  @override
  Future<List<Budget>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = BudgetModel.decode(data);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Budget>> getByMonth(DateTime month) async {
    final all = await getAll();
    return all.where((b) =>
        b.month.year == month.year && b.month.month == month.month).toList();
  }

  @override
  Future<Map<String, double>> getPlannedVsActual(DateTime month) async {
    final items = await getByMonth(month);
    final planned = <String, double>{};
    final actual = <String, double>{};
    final result = <String, double>{};
    for (final item in items) {
      planned[item.category] = (planned[item.category] ?? 0) + item.plannedAmount;
      actual[item.category] = (actual[item.category] ?? 0) + item.actualAmount;
    }
    for (final cat in planned.keys) {
      result[cat] = (planned[cat] ?? 0) - (actual[cat] ?? 0);
    }
    return result;
  }

  @override
  Future<Budget?> getById(String id) async {
    final all = await getAll();
    return all.where((b) => b.id == id).firstOrNull;
  }

  @override
  Future<void> add(Budget budget) async {
    final all = await getAll();
    all.add(budget);
    await _saveAll(all);
  }

  @override
  Future<void> update(Budget budget) async {
    final all = await getAll();
    final index = all.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      all[index] = budget;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((b) => b.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete('all');
  }

  Future<void> _saveAll(List<Budget> items) async {
    final models = items.map((e) => BudgetModel.fromEntity(e)).toList();
    await _box.put('all', BudgetModel.encode(models));
  }
}
