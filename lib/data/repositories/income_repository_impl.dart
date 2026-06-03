import 'package:financial_freedom_management/data/models/income_model.dart';
import 'package:financial_freedom_management/domain/entities/income.dart';
import 'package:financial_freedom_management/domain/repositories/income_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(IncomeModel.boxName);
  }

  @override
  Future<List<Income>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = IncomeModel.decode(data);
    models.sort((a, b) => b.date.compareTo(a.date));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Income>> getByMonth(DateTime month) async {
    final all = await getAll();
    return all.where((i) =>
        i.date.year == month.year && i.date.month == month.month).toList();
  }

  @override
  Future<double> getTotalByMonth(DateTime month) async {
    final items = await getByMonth(month);
    return items.fold<double>(0.0, (sum, i) => sum + i.amount);
  }

  @override
  Future<double> getTotalByYear(int year) async {
    final all = await getAll();
    return all.where((i) => i.date.year == year)
        .fold<double>(0.0, (sum, i) => sum + i.amount);
  }

  @override
  Future<Map<String, double>> getCategoryTotals(DateTime month) async {
    final items = await getByMonth(month);
    final map = <String, double>{};
    for (final item in items) {
      map[item.category] = (map[item.category] ?? 0) + item.amount;
    }
    return map;
  }

  @override
  Future<Income?> getById(String id) async {
    final all = await getAll();
    return all.where((i) => i.id == id).firstOrNull;
  }

  @override
  Future<void> add(Income income) async {
    final all = await getAll();
    all.add(income);
    await _saveAll(all);
  }

  @override
  Future<void> update(Income income) async {
    final all = await getAll();
    final index = all.indexWhere((i) => i.id == income.id);
    if (index != -1) {
      all[index] = income;
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

  Future<void> _saveAll(List<Income> items) async {
    final models = items.map((e) => IncomeModel.fromEntity(e)).toList();
    await _box.put('all', IncomeModel.encode(models));
  }
}
