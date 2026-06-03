import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_freedom_management/core/theme/app_theme.dart';
import 'package:financial_freedom_management/presentation/providers/theme_provider.dart';
import 'package:financial_freedom_management/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:financial_freedom_management/presentation/screens/income/income_screen.dart';
import 'package:financial_freedom_management/presentation/screens/expense/expense_screen.dart';
import 'package:financial_freedom_management/presentation/screens/assets/asset_screen.dart';
import 'package:financial_freedom_management/presentation/screens/liabilities/liability_screen.dart';
import 'package:financial_freedom_management/presentation/screens/networth/networth_screen.dart';
import 'package:financial_freedom_management/presentation/screens/fire/fi_calculator_screen.dart';
import 'package:financial_freedom_management/presentation/screens/fire/fire_planner_screen.dart';
import 'package:financial_freedom_management/presentation/screens/investments/investment_screen.dart';
import 'package:financial_freedom_management/presentation/screens/goals/goals_screen.dart';
import 'package:financial_freedom_management/presentation/screens/budget/budget_screen.dart';
import 'package:financial_freedom_management/presentation/screens/debt/debt_planner_screen.dart';
import 'package:financial_freedom_management/presentation/screens/reports/reports_screen.dart';
import 'package:financial_freedom_management/presentation/screens/score/score_screen.dart';
import 'package:financial_freedom_management/presentation/screens/health/health_screen.dart';
import 'package:financial_freedom_management/presentation/screens/settings/settings_screen.dart';

class FFMApp extends StatelessWidget {
  const FFMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);
        return MaterialApp(
          title: 'Financial Freedom Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const MainShell(),
        );
      },
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _showFullMenu = false;

  final _allScreens = <Widget>[
    const DashboardScreen(),
    const IncomeScreen(),
    const ExpenseScreen(),
    const AssetScreen(),
    const LiabilityScreen(),
    const NetWorthScreen(),
    const FICalculatorScreen(),
    const FIREPlannerScreen(),
    const InvestmentScreen(),
    const SavingsGoalsScreen(),
    const BudgetPlannerScreen(),
    const DebtPlannerScreen(),
    const ReportsScreen(),
    const ScoreScreen(),
    const HealthDashboardScreen(),
    const SettingsScreen(),
  ];

  final _screenTitles = <String>[
    'Dashboard', 'Income', 'Expenses', 'Assets', 'Liabilities',
    'Net Worth', 'FI Calculator', 'FIRE Planner', 'Investments',
    'Savings Goals', 'Budget', 'Debt Planner', 'Reports',
    'FI Score', 'Health', 'Settings',
  ];

  final _screenIcons = <IconData>[
    Icons.dashboard, Icons.arrow_upward, Icons.arrow_downward,
    Icons.account_balance, Icons.credit_card, Icons.trending_up,
    Icons.calculate, Icons.local_fire_department, Icons.pie_chart,
    Icons.flag, Icons.receipt_long, Icons.credit_card_off,
    Icons.description, Icons.star, Icons.favorite, Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = _showFullMenu
        ? List.generate(_allScreens.length, (i) => _NavItem(_screenIcons[i], _screenTitles[i], i))
        : [
            _NavItem(Icons.dashboard, 'Dashboard', 0),
            _NavItem(Icons.arrow_upward, 'Income', 1),
            _NavItem(Icons.arrow_downward, 'Expenses', 2),
            _NavItem(Icons.account_balance, 'Assets', 3),
            _NavItem(Icons.credit_card, 'Debts', 4),
            _NavItem(Icons.trending_up, 'Net Worth', 5),
            _NavItem(Icons.more_horiz, 'More', -1),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _allScreens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          if (i == -1) {
            setState(() => _showFullMenu = !_showFullMenu);
          } else {
            setState(() => _currentIndex = i);
          }
        },
        destinations: navItems.map((item) => NavigationDestination(
          icon: Icon(item.icon),
          label: item.title,
        )).toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_balance, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text('Financial Freedom', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Management', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ...List.generate(_allScreens.length, (i) => ListTile(
            leading: Icon(_screenIcons[i], color: _currentIndex == i ? Theme.of(context).colorScheme.primary : null),
            title: Text(_screenTitles[i], style: TextStyle(fontWeight: _currentIndex == i ? FontWeight.bold : FontWeight.normal)),
            selected: _currentIndex == i,
            onTap: () { setState(() => _currentIndex = i); Navigator.pop(context); },
          )),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: _ScreenSearchDelegate(_screenTitles, _screenIcons, (i) {
      setState(() => _currentIndex = i);
    }));
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final int index;
  _NavItem(this.icon, this.title, this.index);
}

class _ScreenSearchDelegate extends SearchDelegate<int> {
  final List<String> titles;
  final List<IconData> icons;
  final Function(int) onSelected;

  _ScreenSearchDelegate(this.titles, this.icons, this.onSelected);

  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, -1));

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = titles.asMap().entries.where((e) => e.value.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final entry = results[i];
        return ListTile(
          leading: Icon(icons[entry.key]),
          title: Text(entry.value),
          onTap: () { onSelected(entry.key); close(context, entry.key); },
        );
      },
    );
  }
}
