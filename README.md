# Money Tracker

A personal finance iOS app for tracking income and expenses, visualizing spending by category, and running financial calculations.

## Features

- **Transaction tracking** — log income and expenses with categories, notes, and custom dates
- **Category charts** — pie and bar charts (powered by AAChartKit-Swift) showing spending breakdown
- **Multi-currency support** — choose your currency symbol globally
- **Financial Calculators** — built-in loan, budget, and compound interest calculators
- **Localization** — English, Japanese, Simplified Chinese, Traditional Chinese, Traditional Chinese (HK)
- **Ad support** — banner and rewarded ads via Google Mobile Ads; rewarded ads are opt-in to support the app

## Requirements

- iOS 16+
- Xcode 16+
- Swift 5.9+

## Getting Started

1. Clone the repo
2. Open `Money Tracker/Money Tracker.xcodeproj` in Xcode
3. Xcode will automatically resolve Swift Package dependencies on first open
4. Select a simulator or device and run

No CocoaPods or manual dependency steps required.

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
├── AppDelegate.swift
├── Home/               # Transaction list, add/edit, charts
├── Menu/               # Settings, feedback, more apps
├── Calculator/         # Loan, budget, compound interest calculators
├── Model.xcdatamodeld  # Core Data schema
├── Utilities/          # Helpers (store review, constants)
└── Supporting/         # Localization strings
```

## License

© Banghua Zhao. All rights reserved.
