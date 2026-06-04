# Financial Freedom Management (FFM)

Track your income, expenses, assets, liabilities, investments, and path to financial independence.

## Features

- **Dashboard** — Real-time net worth, FI progress, savings rate, emergency fund status
- **Income Manager** — Track salary, business, rental, dividends, interest, side hustles
- **Expense Manager** — Category-based expense tracking with monthly summaries
- **Asset Manager** — Cash, investments, real estate, business, and other assets
- **Liability Manager** — Credit cards, loans, mortgage with outstanding balance & interest rate
- **Net Worth Tracker** — Auto-calculated with historical growth chart
- **FI Calculator** — FI Number, progress, withdrawal rate planning
- **FIRE Planner** — Lean, Regular, and Fat FIRE targets
- **Investment Portfolio** — Holdings, cost basis, gain/loss, allocation pie chart
- **Savings Goals** — Emergency fund, house, retirement, business capital
- **Budget Planner** — Monthly/annual budgets with planned vs actual comparison
- **Debt Elimination Planner** — Snowball and Avalanche methods
- **Reports** — Monthly/quarterly/annual reports with PDF and CSV export
- **Financial Freedom Score** — 0-100 scoring engine
- **Financial Health Dashboard** — Savings rate, debt ratio, FI ratio, asset allocation
- **Settings** — Dark/Light mode, backup/restore

## Installation

### Option 1: Direct Download FFM - Financial Freedom Management Android App

Download the APK below and install on your Android device.

This APK uses a committed release keystore with v1+v2+v3 signing for Android 8+ compatibility.

https://github.com/kyawhn/FFM/releases/download/build-24/app-release.apk

### Option 2: Download from GitHub Actions

1. Go to the **Actions** tab of this repository
2. Click on the latest successful workflow run
3. Scroll to **Artifacts** section
4. Download **`app-release-universal`** (works on all Android devices)
5. Transfer the APK to your Android device
6. Open the file and install (you may need to enable "Install from unknown sources")

### Option 3: Build Locally

```bash
# Clone the repository
git clone https://github.com/kyawhn/FFM.git
cd FFM

# Build debug APK
flutter build apk --debug

# Build universal release APK
flutter build apk --release

# Build split APKs (smaller size, per-architecture)
flutter build apk --release --split-per-abi
```

## Tech Stack

- **Framework:** Flutter (latest stable)
- **Language:** Dart (latest stable)
- **State Management:** Riverpod 2.x
- **Database:** Hive (local-first, offline-only)
- **Charts:** fl_chart
- **Architecture:** Clean Architecture (Presentation → Domain → Data)
- **UI:** Material 3 with dark/light mode

## Project Structure

```
lib/
├── core/           # Constants, theme, utilities
├── data/           # Models, repositories (Hive implementation)
├── domain/         # Entities, repository interfaces
└── presentation/   # Providers (Riverpod), screens
```

## GitHub Actions

The workflow (`.github/workflows/android-build.yml`) automatically:
1. Checks out code
2. Sets up Java 17 + Flutter
3. Generates release keystore
4. Runs `flutter analyze` and `flutter test`
5. Builds debug, universal release, and split-per-abi APKs
6. Verifies APK signatures and generates SHA256 checksums
7. Uploads all APKs as artifacts
