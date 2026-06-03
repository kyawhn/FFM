import 'package:financial_freedom_management/data/models/goal_model.dart';
import 'package:financial_freedom_management/domain/entities/savings_goal.dart';
import 'package:financial_freedom_management/domain/repositories/goal_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GoalRepositoryImpl implements GoalRepository {
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(GoalModel.boxName);
  }

  @override
  Future<List<SavingsGoal>> getAll() async {
    final data = _box.get('all');
    if (data == null) return [];
    final models = GoalModel.decode(data);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SavingsGoal?> getById(String id) async {
    final all = await getAll();
    return all.where((g) => g.id == id).firstOrNull;
  }

  @override
  Future<void> add(SavingsGoal goal) async {
    final all = await getAll();
    all.add(goal);
    await _saveAll(all);
  }

  @override
  Future<void> update(SavingsGoal goal) async {
    final all = await getAll();
    final index = all.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      all[index] = goal;
      await _saveAll(all);
    }
  }

  @override
  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((g) => g.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete('all');
  }

  Future<void> _saveAll(List<SavingsGoal> items) async {
    final models = items.map((e) => GoalModel.fromEntity(e)).toList();
    await _box.put('all', GoalModel.encode(models));
  }
}
