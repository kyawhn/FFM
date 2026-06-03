import 'package:flutter_test/flutter_test.dart';
import 'package:financial_freedom_management/domain/entities/income.dart';
import 'package:financial_freedom_management/domain/entities/expense.dart';
import 'package:financial_freedom_management/domain/entities/asset.dart';
import 'package:financial_freedom_management/domain/entities/liability.dart';
import 'package:financial_freedom_management/domain/entities/savings_goal.dart';
import 'package:financial_freedom_management/domain/entities/investment.dart';
import 'package:financial_freedom_management/domain/entities/budget.dart';
import 'package:financial_freedom_management/domain/entities/debt_plan.dart';
import 'package:financial_freedom_management/core/utils/financial_calculator.dart';

void main() {
  group('Income Entity', () {
    test('should create Income with default createdAt', () {
      final income = Income(id: '1', amount: 5000, category: 'Salary', date: DateTime(2026, 1, 1));
      expect(income.id, '1');
      expect(income.amount, 5000);
      expect(income.category, 'Salary');
    });

    test('copyWith should update fields', () {
      final income = Income(id: '1', amount: 5000, category: 'Salary', date: DateTime(2026, 1, 1));
      final updated = income.copyWith(amount: 6000);
      expect(updated.amount, 6000);
      expect(updated.id, '1');
    });

    test('should support value equality', () {
      final a = Income(id: '1', amount: 1000, category: 'Salary', date: DateTime(2026, 1, 1));
      final b = Income(id: '1', amount: 1000, category: 'Salary', date: DateTime(2026, 1, 1));
      expect(a, b);
    });
  });

  group('Expense Entity', () {
    test('should create Expense correctly', () {
      final expense = Expense(id: '1', amount: 200, category: 'Food', date: DateTime(2026, 1, 1));
      expect(expense.amount, 200);
      expect(expense.category, 'Food');
    });
  });

  group('Asset Entity', () {
    test('should calculate gain/loss correctly', () {
      final asset = Asset(id: '1', name: 'House', type: 'Real Estate', currentValue: 300000, purchaseValue: 250000);
      expect(asset.gainLoss, 50000);
      expect(asset.gainLossPercent, 20.0);
    });

    test('should handle zero purchase value', () {
      final asset = Asset(id: '1', name: 'Gift', type: 'Other', currentValue: 1000, purchaseValue: 0);
      expect(asset.gainLoss, 1000);
      expect(asset.gainLossPercent, 0);
    });
  });

  group('Liability Entity', () {
    test('should create liability correctly', () {
      final liability = Liability(id: '1', name: 'Mortgage', type: 'Mortgage', outstandingBalance: 200000, interestRate: 5.5, dueDate: DateTime(2030, 1, 1));
      expect(liability.outstandingBalance, 200000);
      expect(liability.interestRate, 5.5);
    });
  });

  group('SavingsGoal Entity', () {
    test('should calculate progress correctly', () {
      final goal = SavingsGoal(id: '1', name: 'Emergency Fund', type: 'Emergency Fund', goalAmount: 10000, currentAmount: 5000, targetDate: DateTime(2027, 1, 1));
      expect(goal.progress, 50.0);
      expect(goal.remaining, 5000);
    });
  });

  group('Investment Entity', () {
    test('should calculate gain/loss correctly', () {
      final inv = Investment(id: '1', name: 'AAPL', type: 'Stocks', costBasis: 150, currentValue: 180, quantity: 10, purchaseDate: DateTime(2025, 1, 1));
      expect(inv.gainLoss, 300);
      expect(inv.gainLossPercent, 20.0);
    });
  });

  group('Budget Entity', () {
    test('should calculate variance correctly', () {
      final budget = Budget(id: '1', category: 'Food', plannedAmount: 500, actualAmount: 450, month: DateTime(2026, 1, 1));
      expect(budget.variance, 50);
      expect(budget.variancePercent, 10.0);
    });
  });

  group('FinancialCalculator', () {
    test('calculateNetWorth', () {
      expect(FinancialCalculator.calculateNetWorth(100000, 60000), 40000);
    });

    test('calculateSavingsRate', () {
      expect(FinancialCalculator.calculateSavingsRate(5000, 3000), 40.0);
      expect(FinancialCalculator.calculateSavingsRate(0, 3000), 0);
    });

    test('calculateEmergencyFundMonths', () {
      expect(FinancialCalculator.calculateEmergencyFundMonths(12000, 6000), 6.0);
    });

    test('calculateFI', () {
      final fi = FinancialCalculator.calculateFI(40000, 0.04);
      expect(fi, 1000000);
    });

    test('calculateFIProgress', () {
      expect(FinancialCalculator.calculateFIProgress(250000, 1000000), 25.0);
    });

    test('calculateDebtRatio', () {
      expect(FinancialCalculator.calculateDebtRatio(30000, 100000), 30.0);
    });

    test('calculateScore', () {
      final score = FinancialCalculator.calculateScore(
        savingsRate: 30, debtRatio: 20, emergencyFundMonths: 6,
        investmentRate: 25, netWorthGrowth: 10,
      );
      expect(score.totalScore, greaterThan(0));
      expect(score.totalScore, lessThanOrEqualTo(100));
      expect(score.rating, isNotEmpty);
    });
  });

  group('DebtPlan', () {
    test('should calculate payoff metrics', () {
      final plan = DebtPlan(id: '1', name: 'CC Debt', totalDebt: 10000, monthlyPayment: 500, interestRate: 18, method: 'Snowball', startDate: DateTime(2026, 1, 1));
      expect(plan.monthsToPayoff, greaterThan(0));
      expect(plan.totalInterest, greaterThan(0));
      expect(plan.payoffDate, isNotNull);
    });
  });
}
