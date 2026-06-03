import 'package:flutter_test/flutter_test.dart';
import 'package:financial_freedom_management/data/models/income_model.dart';
import 'package:financial_freedom_management/data/models/expense_model.dart';
import 'package:financial_freedom_management/data/models/asset_model.dart';
import 'package:financial_freedom_management/data/models/liability_model.dart';
import 'package:financial_freedom_management/data/models/goal_model.dart';
import 'package:financial_freedom_management/data/models/investment_model.dart';
import 'package:financial_freedom_management/data/models/budget_model.dart';
import 'package:financial_freedom_management/domain/entities/income.dart';
import 'package:financial_freedom_management/domain/entities/expense.dart';
import 'package:financial_freedom_management/domain/entities/asset.dart';
import 'package:financial_freedom_management/domain/entities/liability.dart';
import 'package:financial_freedom_management/domain/entities/savings_goal.dart';
import 'package:financial_freedom_management/domain/entities/investment.dart';
import 'package:financial_freedom_management/domain/entities/budget.dart';

void main() {
  group('IncomeModel', () {
    test('should convert to/from entity', () {
      final entity = Income(id: '1', amount: 5000, category: 'Salary', date: DateTime(2026, 1, 1));
      final model = IncomeModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.amount, entity.amount);
      expect(model.category, entity.category);

      final converted = model.toEntity();
      expect(converted.id, entity.id);
      expect(converted.amount, entity.amount);
    });

    test('toJson and fromJson should roundtrip', () {
      final model = IncomeModel(id: '1', amount: 5000, category: 'Salary', date: DateTime(2026, 1, 1), notes: 'Test', createdAt: DateTime(2026, 1, 1));
      final json = model.toJson();
      final decoded = IncomeModel.fromJson(json);
      expect(decoded.id, model.id);
      expect(decoded.amount, model.amount);
      expect(decoded.notes, model.notes);
    });
  });

  group('ExpenseModel', () {
    test('should convert to/from entity', () {
      final entity = Expense(id: '1', amount: 200, category: 'Food', date: DateTime(2026, 1, 1));
      final model = ExpenseModel.fromEntity(entity);
      expect(model.amount, 200);
      final converted = model.toEntity();
      expect(converted.amount, 200);
    });
  });

  group('AssetModel', () {
    test('should convert to/from entity', () {
      final entity = Asset(id: '1', name: 'House', type: 'Real Estate', currentValue: 300000, purchaseValue: 250000);
      final model = AssetModel.fromEntity(entity);
      expect(model.name, 'House');
      expect(model.currentValue, 300000);
      final converted = model.toEntity();
      expect(converted.currentValue, 300000);
    });
  });

  group('LiabilityModel', () {
    test('should convert to/from entity', () {
      final entity = Liability(id: '1', name: 'Loan', type: 'Personal Loan', outstandingBalance: 10000, interestRate: 5, dueDate: DateTime(2026, 6, 1));
      final model = LiabilityModel.fromEntity(entity);
      expect(model.outstandingBalance, 10000);
    });
  });

  group('GoalModel', () {
    test('should convert to/from entity', () {
      final entity = SavingsGoal(id: '1', name: 'Fund', type: 'Emergency Fund', goalAmount: 10000, currentAmount: 5000, targetDate: DateTime(2027, 1, 1));
      final model = GoalModel.fromEntity(entity);
      expect(model.goalAmount, 10000);
    });
  });

  group('InvestmentModel', () {
    test('should convert to/from entity', () {
      final entity = Investment(id: '1', name: 'AAPL', type: 'Stocks', costBasis: 150, currentValue: 180, quantity: 10, purchaseDate: DateTime(2025, 1, 1));
      final model = InvestmentModel.fromEntity(entity);
      expect(model.name, 'AAPL');
      expect(model.quantity, 10);
    });
  });

  group('BudgetModel', () {
    test('should convert to/from entity', () {
      final entity = Budget(id: '1', category: 'Food', plannedAmount: 500, actualAmount: 450, month: DateTime(2026, 1, 1));
      final model = BudgetModel.fromEntity(entity);
      expect(model.plannedAmount, 500);
    });
  });
}
