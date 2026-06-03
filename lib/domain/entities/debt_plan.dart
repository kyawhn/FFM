import 'package:equatable/equatable.dart';

class DebtPlan extends Equatable {
  final String id;
  final String name;
  final double totalDebt;
  final double monthlyPayment;
  final double interestRate;
  final String method;
  final DateTime startDate;

  const DebtPlan({
    required this.id,
    required this.name,
    required this.totalDebt,
    required this.monthlyPayment,
    required this.interestRate,
    required this.method,
    required this.startDate,
  });

  double get monthsToPayoff {
    if (monthlyPayment <= 0 || interestRate < 0) return double.infinity;
    final monthlyRate = interestRate / 100 / 12;
    if (monthlyRate == 0) return totalDebt / monthlyPayment;
    final numerator = -log(1 - monthlyRate * totalDebt / monthlyPayment);
    final denominator = log(1 + monthlyRate);
    if (denominator == 0 || numerator.isNaN || numerator.isInfinite) return double.infinity;
    return numerator / denominator;
  }

  double get totalInterest {
    final months = monthsToPayoff;
    if (months.isInfinite || months.isNaN) return double.infinity;
    return (monthlyPayment * months) - totalDebt;
  }

  DateTime get payoffDate {
    final months = monthsToPayoff;
    if (months.isInfinite || months.isNaN) return startDate;
    return DateTime(startDate.year, startDate.month + months.ceil(), startDate.day);
  }

  @override
  List<Object?> get props => [id, name, totalDebt, monthlyPayment, interestRate, method, startDate];
}
