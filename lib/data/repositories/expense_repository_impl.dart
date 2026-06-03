import 'package:financial_freedom_management/data/models/expense_model.dart';
import 'package:financial_freedom_management/domain/entities/expense.dart';
import 'package:financial_freedom_management/domain/repositories/expense_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(ExpenseModel.boxName);
  }

  @override
  Future<List<Expense>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = ExpenseModel.decode(data);
    models.sort((a, b) => b.date.compareTo(a.date));
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getByMonth(DateTime month) async {
    final all = await getAll();
    return all.where((e) =>
        e.date.year == month.year && e.date.month == month.month).toList();
  }

  @override
  Future<double> getTotalByMonth(DateTime month) async {
    final items = await getByMonth(month);
    return items.fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Future<double> getTotalByYear(int year) async {
    final all = await getAll();
    return all.where((e) => e.date.year == year)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
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
  Future<Expense?> getById(String id) async {
    final all = await getAll();
    return all.where((e) => e.id == id).firstOrNull;
  }

  @override
  Future<void> add(Expense expense) async {
    final all = await getAll();
    all.add(expense);
    await _saveAll(all);
  }

  @override
  Future<void> update(Expense expense) async {
    final all = await getAll();
    final index = all.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      all[index] = expense;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete('all');
  }

  Future<void> _saveAll(List<Expense> items) async {
    final models = items.map((e) => ExpenseModel.fromEntity(e)).toList();
    await _box.put('all', ExpenseModel.encode(models));
  }
}
