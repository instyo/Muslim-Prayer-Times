# Agent Instructions

## Build & Run

- Open `Muslim Prayer Times.xcodeproj` in Xcode
- Or build via CLI: `xcodebuild -project "Muslim Prayer Times.xcodeproj" -scheme "Muslim Prayer Times" -configuration Debug build`

## Project Structure

```
Muslim Prayer Times/
├── Models/           # Data models (PrayerModel, QiblaModel)
├── Services/         # API & location services
├── View Models/     # SwiftUI view models
├── Views/           # SwiftUI views
│   ├── Prayer/      # Prayer times screens
│   └── Qibla/       # Qibla direction screen
└── Utils/           # Helper functions
```

## Key Conventions

- App entry: `Muslim_Prayer_TimesApp.swift` → `ContentView`
- Location service required at startup - handles permission flow
- Uses CoreLocation for user location
- API service fetches prayer times from external API

## Important Files

- `Views/ContentView.swift`: Root view with location permission handling
- `Services/LocationService.swift`: CoreLocation wrapper
- `Services/PrayerAPIService.swift`: Prayer times API client
- `View Models/PrayerViewModel.swift`: Main prayer times logic

## Dependencies

- No external dependencies (pure SwiftUI + native frameworks)
- Frameworks: SwiftUI, CoreLocation, Foundation