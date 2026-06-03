import 'package:equatable/equatable.dart';

class NetWorthSnapshot extends Equatable {
  final DateTime date;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;

  const NetWorthSnapshot({
    required this.date,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  @override
  List<Object?> get props => [date, totalAssets, totalLiabilities, netWorth];
}
