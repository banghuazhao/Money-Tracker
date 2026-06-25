# Money Tracker

A personal finance iOS app for tracking income and expenses, visualizing net worth and spending by category, and running financial calculations — built with UIKit and Core Data.

📲 **[Download on the App Store](https://apps.apple.com/app/id1534244892)**

## Features

- **Net worth tracking** — log income and expenses with categories, notes, and custom dates; see your net worth trend over time on an interactive area chart
- **Tab-based navigation** — Net Worth, Financial Calculators, and More (Settings) tabs
- **Spending insights** — pie and bar charts (powered by AAChartKit-Swift) breaking down income and expenses by category, plus a searchable transaction list
- **7 financial calculators** — Loan, Compound Interest, Budget Planner (50/30/20), Savings Goal, Retirement, Debt Payoff, and Tip Split
- **Multi-currency support** — pick your currency symbol globally
- **Localization** — English, Japanese, Simplified Chinese, Traditional Chinese, and Traditional Chinese (Hong Kong)
- **Monetization** — banner, app-open, interstitial, and opt-in rewarded ads via Google Mobile Ads, tuned to stay unobtrusive

## Requirements

- iOS 16+
- Xcode 16+
- Swift 5.9+

## Getting Started

1. Clone the repo
2. Set up the AdMob config (see below)
3. Open `Money Tracker/Money Tracker.xcodeproj` in Xcode
4. Xcode automatically resolves the Swift Package dependencies on first open
5. Select a simulator or device and run

No CocoaPods or manual dependency steps required.

### AdMob configuration

Ad unit IDs are injected per build configuration via `.xcconfig` files (referenced from `Info.plist`, read at runtime in `Constants.swift`):

- `Config/Debug.xcconfig` — Google **test** ad IDs, committed to the repo. Debug builds work out of the box.
- `Config/Release.xcconfig` — your **production** ad IDs. This file is **git-ignored**. Copy the template and fill in your own IDs:

  ```sh
  cp "Money Tracker/Money Tracker/Config/Release.xcconfig.example" \
     "Money Tracker/Money Tracker/Config/Release.xcconfig"
  ```

  Then set `GADApplicationIdentifier`, `bannerViewAdUnitID`, `appOpenAdID`, `interstitialAdID`, and `rewardAdUnitID`.

## Dependencies (Swift Package Manager)

| Package | Purpose |
|---|---|
| [SnapKit](https://github.com/SnapKit/SnapKit) | Auto Layout DSL |
| [Then](https://github.com/devxoul/Then) | Initializer sugar |
| [SwiftDate](https://github.com/malcommac/SwiftDate) | Date parsing and formatting |
| [AAChartKit-Swift](https://github.com/AAChartModel/AAChartKit-Swift) | Charts |
| [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) | Keyboard handling |
| [Localize-Swift](https://github.com/marmelroy/Localize-Swift) | Localization helpers |
| [Sheeeeeeeeet](https://github.com/danielsaidi/Sheeeeeeeeet) | Action sheets |
| [GoogleMobileAds](https://github.com/googleads/swift-package-manager-google-mobile-ads) | Ads |
| [ProgressHUD](https://github.com/relatedcode/ProgressHUD) | Loading indicators |

## Project Structure

```
Money Tracker/
├── AppDelegate.swift     # Tab bar setup, ad bootstrapping
├── Home/                 # Net worth chart, transaction list, add/edit, category charts
├── Calculator/           # 7 financial calculators
├── Menu/                 # Settings, feedback, more apps
├── Config/               # AdMob xcconfig files (Debug committed, Release ignored)
├── Model.xcdatamodeld    # Core Data schema
├── Utilities/            # Helpers (ad managers, store review, constants, extensions)
└── Supporting/           # Localization strings
```

## Architecture

- **UIKit** with programmatic Auto Layout (SnapKit)
- **Core Data** for local persistence of transactions
- **MVC** with view controllers per screen and reusable cell views

## License

© Banghua Zhao. All rights reserved.
