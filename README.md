# Muslim Prayer Times

A native iOS app that provides accurate prayer times, Qibla direction, and Islamic calendar dates based on your location. Built with SwiftUI and CoreLocation.

## Features

- **Prayer Times** - Daily prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) based on your GPS location
- **Current Prayer** - Shows which prayer is currently ongoing or upcoming
- **Qibla Direction** - Compass pointing toward the Kaaba in Mecca
- **Islamic Calendar** - Displays Hijri and Gregorian dates
- **Home Screen Widget** - Quick glance at prayer times from your home screen
- **Location-based** - Automatically adjusts prayer times based on your current position

## Screenshots

| Screen 1 | Screen 2 | Screen 3 | Screen 4 | Screen 5 | Screen 6 |
|----------|----------|----------|----------|----------|----------|
| ![Screen 1](https://raw.githubusercontent.com/instyo/Muslim-Prayer-Times/refs/heads/main/Screenshots/1.png)    | ![Screen 2](https://raw.githubusercontent.com/instyo/Muslim-Prayer-Times/refs/heads/main/Screenshots/2.png)    | ![Screen 3](https://raw.githubusercontent.com/instyo/Muslim-Prayer-Times/refs/heads/main/Screenshots/3.png)    | ![Screen 4](https://raw.githubusercontent.com/instyo/Muslim-Prayer-Times/refs/heads/main/Screenshots/4.png)    | ![Screen 5](https://raw.githubusercontent.com/instyo/Muslim-Prayer-Times/refs/heads/main/Screenshots/5.png)    | ![Screen 6](https://raw.githubusercontent.com/instyo/Muslim-Prayer-Times/refs/heads/main/Screenshots/6.png)   |

## Prerequisites

- **iOS 17.0+** - Required for modern SwiftUI features
- **Xcode 15.0+** - For building the project
- **iPhone** - Physical device (location services work best on real devices)
- **Internet** - Required to fetch prayer times data

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ikhwanSetyo/Muslim-Prayer-Times.git
cd Muslim-Prayer-Times
```

### 2. Get Your API Key

1. Go to [Islamic API](https://islamicapi.com/signup/)
2. Create a free account
3. Obtain your API key

### 3. Replace the API Key

Open `Muslim Prayer Times/Services/PrayerAPIService.swift` and replace `YOUR_API_KEY_HERE` with your actual API key:

```swift
// Before
let urlString = "https://islamicapi.com/api/v1/prayer-time/?lat=\(latitude)&lon=\(longitude)&api_key=YOUR_API_KEY_HERE"

// After
let urlString = "https://islamicapi.com/api/v1/prayer-time/?lat=\(latitude)&lon=\(longitude)&api_key=your_actual_key_here"
```

Open `PrayerWidget/PrayerWidget.swift` and replace `YOUR_API_KEY_HERE` with your actual API key:

```swift
// Before
let apiKey = "YOUR_API_KEY_HERE"

// After
let apiKey = "your_actual_key_here"
```

**Note**: The app will not work until you provide a valid API key.

## Build & Run

### Using Xcode

1. Open `Muslim Prayer Times.xcodeproj` in Xcode
2. Select your target device (iPhone)
3. Press `Cmd + R` to build and run

### Using Command Line

```bash
xcodebuild -project "Muslim Prayer Times.xcodeproj" -scheme "Muslim Prayer Times" -configuration Debug build
```

## Project Structure

```
Muslim Prayer Times/
├── Models/
│   ├── PrayerModel.swift      # Prayer times data models
│   └── QiblaModel.swift      # Qibla direction models
├── Services/
│   ├── PrayerAPIService.swift   # Prayer times API client
│   └── LocationService.swift    # CoreLocation wrapper
├── View Models/
│   ├── PrayerViewModel.swift    # Prayer times logic
│   └── QiblaViewModel.swift     # Qibla direction logic
├── Views/
│   ├── ContentView.swift       # Root view
│   ├── MainTabView.swift       # Tab navigation
│   ├── LocationPermissionView.swift
│   ├── ErrorView.swift
│   ├── Prayer/
│   │   ├── PrayerView.swift         # Prayer times list
│   │   ├── CurrentPrayerCard.swift  # Current prayer display
│   │   └── PrayerRowView.swift      # Individual prayer row
│   └── Qibla/
│       └── QiblaView.swift     # Qibla compass
├── Utils/
│   └── PrayerTimeHelper.swift  # Helper functions
└── Assets.xcassets/          # App icons and colors

PrayerWidget/
├── PrayerWidget.swift        # Home screen widget
├── PrayerWidgetControl.swift  # Widget configuration
└── AppIntent.swift           # Widget intents
```

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models** - Data structures and API response models
- **Views** - SwiftUI views (pure UI)
- **View Models** - Business logic and state management
- **Services** - API and location services

## Tech Stack

- **SwiftUI** - UI framework
- **CoreLocation** - GPS and location services
- **WidgetKit** - iOS Home Screen widgets
- **No external dependencies** - Pure Apple frameworks only

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
