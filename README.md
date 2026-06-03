# Financial Freedom Management (FFM)

A comprehensive Flutter application for tracking personal finances and achieving financial independence.

## Features

- **Dashboard** - Real-time overview of net worth, savings rate, FI progress, and financial health
- **Income Manager** - Track salary, business, rental, dividends, and other income sources
- **Expense Manager** - Monitor spending across 10+ categories with daily entry and analysis
- **Asset Manager** - Track cash, investments, real estate, business assets, and more
- **Liability Manager** - Monitor credit cards, loans, mortgages with interest rates and due dates
- **Net Worth Tracker** - Automatic calculation with historical tracking and charts
- **FI Calculator** - Calculate your Financial Independence Number
- **FIRE Planner** - Lean FIRE, Regular FIRE, and Fat FIRE projections
- **Investment Portfolio** - Track holdings, cost basis, gains/losses with allocation charts
- **Savings Goals** - Set and track goals like emergency fund, house, retirement
- **Budget Planner** - Monthly/annual budgets with planned vs actual comparison
- **Debt Elimination Planner** - Snowball and Avalanche methods with payoff projections
- **Reports** - Monthly, quarterly, annual reports with CSV export
- **Financial Freedom Score** - 0-100 scoring engine with color-coded ratings
- **Financial Health Dashboard** - Visual health metrics and gauges
- **Dark/Light Mode** - Theme support with Material 3

## Architecture

Clean Architecture with three layers:

- **Presentation** - Flutter widgets, Riverpod providers, screens
- **Domain** - Entities, repository interfaces, business logic
- **Data** - Hive database, repository implementations, models

## Tech Stack

- **Framework**: Flutter 3.44+ (Material 3)
- **State Management**: Riverpod 2.x
- **Database**: Hive (local-first, offline)
- **Charts**: fl_chart
- **Architecture**: Clean Architecture

## Getting Started

### Prerequisites

- Flutter SDK 3.44+
- Dart 3.12+
- Android SDK 26+

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/FFM.git
cd FFM

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Building APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

## GitHub Actions

The project includes automatic Android build workflow (`.github/workflows/android-build.yml`) that:

1. Triggers on push to main/develop
2. Installs Flutter
3. Runs `flutter pub get`
4. Runs `flutter analyze`
5. Runs tests
6. Builds debug and release APKs
7. Uploads artifacts

## License

MIT
