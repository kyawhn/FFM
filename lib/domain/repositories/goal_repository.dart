import 'package:financial_freedom_management/domain/entities/savings_goal.dart';

abstract class GoalRepository {
  Future<List<SavingsGoal>> getAll();
  Future<SavingsGoal?> getById(String id);
  Future<void> add(SavingsGoal goal);
  Future<void> update(SavingsGoal goal);
  Future<void> delete(String id);
  Future<void> clearAll();
}
