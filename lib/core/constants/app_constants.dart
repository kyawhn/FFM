class AppConstants {
  static const String appName = 'Financial Freedom Management';
  static const String shortName = 'FFM';
  static const double maxScore = 100.0;
  static const double minWithdrawalRate = 0.02;
  static const double maxWithdrawalRate = 0.10;
  static const double defaultWithdrawalRate = 0.04;

  static const List<String> incomeCategories = [
    'Salary', 'Business', 'Rental', 'Dividends', 'Interest', 'Side Hustles', 'Other'
  ];

  static const List<String> expenseCategories = [
    'Housing', 'Food', 'Transportation', 'Healthcare', 'Education',
    'Entertainment', 'Debt Payments', 'Utilities', 'Insurance', 'Miscellaneous'
  ];

  static const List<String> assetTypes = [
    'Cash', 'Bank Account', 'Stocks', 'ETFs', 'Mutual Funds', 'Bonds',
    'Crypto', 'Business', 'Equipment', 'Real Estate', 'Land', 'Gold', 'Collectibles'
  ];

  static const List<String> liabilityTypes = [
    'Credit Card', 'Personal Loan', 'Mortgage', 'Car Loan', 'Business Loan'
  ];

  static const List<String> fireTypes = ['Lean FIRE', 'Regular FIRE', 'Fat FIRE'];

  static const Map<String, double> fireMultipliers = {
    'Lean FIRE': 0.5,
    'Regular FIRE': 1.0,
    'Fat FIRE': 2.0,
  };

  static const List<String> goalTypes = [
    'Emergency Fund', 'House', 'Retirement', 'Business Capital', 'Vacation', 'Other'
  ];

  static const List<String> debtMethods = ['Snowball', 'Avalanche'];
}
