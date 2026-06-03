import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:financial_freedom_management/presentation/providers/dashboard_provider.dart';
import 'package:financial_freedom_management/core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: dashboardAsync.when(
        data: (data) => _buildDashboard(context, theme, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDashboard(BuildContext context, ThemeData theme, DashboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Financial Overview', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildNetWorthCard(context, theme, data),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard(context, theme, 'Total Assets', '\$${_format(data.totalAssets)}', AppTheme.successColor, Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context, theme, 'Total Liabilities', '\$${_format(data.totalLiabilities)}', AppTheme.errorColor, Icons.trending_down)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard(context, theme, 'Income', '\$${_format(data.monthlyIncome)}', AppTheme.secondaryColor, Icons.arrow_upward)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context, theme, 'Expenses', '\$${_format(data.monthlyExpenses)}', AppTheme.warningColor, Icons.arrow_downward)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard(context, theme, 'Savings Rate', '${data.savingsRate.toStringAsFixed(1)}%', AppTheme.accentColor, Icons.savings)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context, theme, 'FI Progress', '${data.fiProgress.toStringAsFixed(1)}%', AppTheme.primaryColor, Icons.flag)),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressCard(context, theme, 'FI Number: \$${_format(data.fiNumber)}', data.fiProgress / 100, AppTheme.accentColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard(context, theme, 'Emergency Fund', '${data.emergencyFundMonths.toStringAsFixed(1)}mo', data.emergencyFundMonths >= 6 ? AppTheme.successColor : AppTheme.warningColor, Icons.shield)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard(context, theme, 'Debt Ratio', '${data.debtRatio.toStringAsFixed(1)}%', data.debtRatio < 30 ? AppTheme.successColor : AppTheme.errorColor, Icons.balance)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInvestmentCard(context, theme, data),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNetWorthCard(BuildContext context, ThemeData theme, DashboardData data) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Net Worth', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('\$${_format(data.netWorth)}',
                style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: data.netWorth > 0 ? 1.0 : 0.0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assets: \$${_format(data.totalAssets)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('Liabilities: \$${_format(data.totalLiabilities)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.1, duration: 500.ms).shake();
  }

  Widget _buildMetricCard(BuildContext context, ThemeData theme, String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildProgressCard(BuildContext context, ThemeData theme, String label, double progress, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(1)}% Complete', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.1, duration: 500.ms);
  }

  Widget _buildInvestmentCard(BuildContext context, ThemeData theme, DashboardData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Text('Investments', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Text('\$${_format(data.investmentValue)}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Towards FI Number: \$${_format(data.fiNumber)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, duration: 500.ms);
  }

  String _format(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(2)}B';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(2);
  }
}
