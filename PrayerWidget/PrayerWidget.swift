//
//  PrayerWidget.swift
//  PrayerWidget
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Data Models

struct WidgetPrayerTimes: Codable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String

    func time(for prayer: String) -> String {
        switch prayer.lowercased() {
        case "fajr": return fajr
        case "sunrise": return sunrise
        case "dhuhr": return dhuhr
        case "asr": return asr
        case "maghrib": return maghrib
        case "isha": return isha
        default: return ""
        }
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
    let prayerTimes: WidgetPrayerTimes
    let locationName: String
}

// MARK: - Timeline Provider

struct Provider: AppIntentTimelineProvider {
    private let appGroupID = "group.insaneworks.space.MuslimPrayerTimes"
    
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
    }

    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: Date(), prayerTimes: placeholderPrayerTimes(), locationName: "Jakarta")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> PrayerEntry {
        PrayerEntry(date: Date(), prayerTimes: placeholderPrayerTimes(), locationName: "Jakarta")
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<PrayerEntry> {
        let location = loadLocation()
        
        #if DEBUG
        print("Widget: Loading location from App Groups: \(location.map { "\($0.latitude), \($0.longitude)" } ?? "nil")")
        #endif
        
        let prayerTimes: WidgetPrayerTimes
        let locationName: String
        if let loc = location {
            do {
                prayerTimes = try await fetchPrayerTimes(latitude: loc.latitude, longitude: loc.longitude)
                locationName = loc.cityName.isEmpty ? "Unknown" : loc.cityName
                #if DEBUG
                print("Widget: Successfully fetched prayer times")
                #endif
            } catch {
                #if DEBUG
                print("Widget: Failed to fetch prayer times: \(error)")
                #endif
                prayerTimes = placeholderPrayerTimes()
                locationName = location?.cityName ?? "Unknown"
            }
        } else {
            #if DEBUG
            print("Widget: No location available, using placeholder")
            #endif
            prayerTimes = placeholderPrayerTimes()
            locationName = "Unknown"
        }

        let currentDate = Date()
        var entries: [PrayerEntry] = []

        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            entries.append(PrayerEntry(date: entryDate, prayerTimes: prayerTimes, locationName: locationName))
        }

        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: entries, policy: .after(nextHour))
    }

    private func loadLocation() -> (latitude: Double, longitude: Double, cityName: String)? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let locationData = defaults.dictionary(forKey: "userLocation"),
              let lat = locationData["latitude"] as? Double,
              let lon = locationData["longitude"] as? Double else {
            return nil
        }
        let cityName = locationData["cityName"] as? String ?? ""
        return (lat, lon, cityName)
    }

    private func fetchPrayerTimes(latitude: Double, longitude: Double) async throws -> WidgetPrayerTimes {
        let urlString = "https://islamicapi.com/api/v1/prayer-time/?lat=\(latitude)&lon=\(longitude)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }

        let decoded = try JSONDecoder().decode(WidgetAPIResponse.self, from: data)
        return WidgetPrayerTimes(
            fajr: decoded.data.times.fajr,
            sunrise: decoded.data.times.sunrise,
            dhuhr: decoded.data.times.dhuhr,
            asr: decoded.data.times.asr,
            maghrib: decoded.data.times.maghrib,
            isha: decoded.data.times.isha
        )
    }

    private func placeholderPrayerTimes() -> WidgetPrayerTimes {
        WidgetPrayerTimes(
            fajr: "04:30",
            sunrise: "05:45",
            dhuhr: "12:30",
            asr: "15:45",
            maghrib: "18:30",
            isha: "20:00"
        )
    }
}

// MARK: - API Response Models

struct WidgetAPIResponse: Codable {
    let code: Int
    let status: String
    let data: WidgetPrayerResponse
}

struct WidgetPrayerResponse: Codable {
    let times: WidgetPrayerTimesRaw
}

struct WidgetPrayerTimesRaw: Codable {
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String

    enum CodingKeys: String, CodingKey {
        case fajr = "Fajr"
        case sunrise = "Sunrise"
        case dhuhr = "Dhuhr"
        case asr = "Asr"
        case maghrib = "Maghrib"
        case isha = "Isha"
    }
}

// MARK: - Error

enum APIError: Error {
    case invalidURL
    case requestFailed
}

// MARK: - Widget View

struct PrayerWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    private let prayers: [(name: String, key: String)] = [
        ("Fajr", "fajr"),
        ("Sunrise", "sunrise"),
        ("Dhuhr", "dhuhr"),
        ("Asr", "asr"),
        ("Maghrib", "maghrib"),
        ("Isha", "isha")
    ]

    private let accentGreen = Color(red: 0.39, green: 0.82, blue: 0.63)
    private let bgColor = Color(red: 0.05, green: 0.11, blue: 0.16)

    private var currentPrayerKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        var prayerDates: [(key: String, date: Date)] = []
        let now = Date()
        let calendar = Calendar.current

        for prayer in prayers {
            let timeStr = entry.prayerTimes.time(for: prayer.key)
            if let parsed = formatter.date(from: timeStr) {
                let components = calendar.dateComponents([.hour, .minute], from: parsed)
                if let scheduled = calendar.date(
                    bySettingHour: components.hour ?? 0,
                    minute: components.minute ?? 0,
                    second: 0,
                    of: now
                ) {
                    prayerDates.append((key: prayer.key, date: scheduled))
                }
            }
        }

        let past = prayerDates.filter { $0.date <= now }
        return past.last?.key ?? "fajr"
    }

    private var nextPrayerKey: String {
        let currentIndex = prayers.firstIndex { $0.key == currentPrayerKey } ?? 0
        let nextIndex = currentIndex + 1
        guard nextIndex < prayers.count else { return prayers[0].key }
        return prayers[nextIndex].key
    }

    private var currentPrayerName: String {
        prayers.first { $0.key == currentPrayerKey }?.name ?? "Fajr"
    }

    private var nextPrayerName: String {
        prayers.first { $0.key == nextPrayerKey }?.name ?? "Dhuhr"
    }

    private func progressForPrayer(key: String) -> Double {
        guard key == currentPrayerKey else { return 0 }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let now = Date()
        let calendar = Calendar.current

        func toDate(_ timeStr: String) -> Date? {
            guard let parsed = formatter.date(from: timeStr) else { return nil }
            let components = calendar.dateComponents([.hour, .minute], from: parsed)
            return calendar.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: now)
        }

        let keys = prayers.map { $0.key }
        guard let index = keys.firstIndex(of: key) else { return 0 }
        let nextIndex = index + 1

        guard nextIndex < prayers.count,
              let start = toDate(entry.prayerTimes.time(for: key)),
              let end = toDate(entry.prayerTimes.time(for: prayers[nextIndex].key)) else {
            return 0
        }

        let total = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        return min(max(elapsed / total, 0), 1)
    }

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryRectangular:
            accessoryRectangularWidget
        default:
            largeWidget
        }
    }

    private func iconForPrayer(_ key: String) -> String {
        switch key {
        case "fajr": return "sunrise.fill"
        case "sunrise": return "sunrise.fill"
        case "dhuhr": return "sun.max.fill"
        case "asr": return "sun.min.fill"
        case "maghrib": return "sunset.fill"
        case "isha": return "moon.fill"
        default: return "moon.fill"
        }
    }

    var accessoryRectangularWidget: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: iconForPrayer(currentPrayerKey))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text(currentPrayerName)
                        .font(.system(size: 12, weight: .semibold))
                        .widgetAccentable()
                }
                HStack(spacing: 4) {
                    Image(systemName: iconForPrayer(nextPrayerKey))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    Text(nextPrayerName)
                        .font(.system(size: 12))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(entry.prayerTimes.time(for: currentPrayerKey))
                    .font(.system(size: 12, weight: .semibold))
                Text(entry.prayerTimes.time(for: nextPrayerKey))
                    .font(.system(size: 12))
            }
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
    }

    // MARK: - Small

    var smallWidget: some View {
        VStack(spacing: 0) {
            HStack {
                Text(entry.locationName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.38))
                Spacer()
                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.22))
            }
            .padding(.bottom, 4)
            
            ForEach(prayers, id: \.key) { prayer in
                let isActive = prayer.key == currentPrayerKey
                HStack(spacing: 4) {
                    Image(systemName: iconForPrayer(prayer.key))
                        .font(.system(size: 10))
                        .foregroundColor(isActive ? accentGreen : .white.opacity(0.25))
                        .frame(width: 14)
                    Text(prayer.name)
                        .font(.system(size: 11, weight: isActive ? .medium : .regular))
                        .foregroundColor(isActive ? accentGreen : .white.opacity(0.38))

                    Spacer()

                    if isActive {
                        Circle()
                            .fill(accentGreen.opacity(0.8))
                            .frame(width: 4, height: 4)
                    }

                    Text(entry.prayerTimes.time(for: prayer.key))
                        .font(.system(size: 11, weight: isActive ? .medium : .regular))
                        .foregroundColor(isActive ? .white.opacity(0.88) : .white.opacity(0.38))
                        .monospacedDigit()
                }
                .padding(.vertical, 2)
            }
        }
        .containerBackground(for: .widget) { bgColor }
    }

    // MARK: - Medium

    var mediumWidget: some View {
        VStack(spacing: 0) {
            HStack {
                Text(entry.locationName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.38))
                Spacer()
                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.22))
            }
            .padding(.bottom, 6)
            
            ForEach(prayers, id: \.key) { prayer in
                let isActive = prayer.key == currentPrayerKey
                let progress = progressForPrayer(key: prayer.key)

                HStack(spacing: 6) {
                    Image(systemName: iconForPrayer(prayer.key))
                        .font(.system(size: 10))
                        .foregroundColor(isActive ? accentGreen : .white.opacity(0.25))
                        .frame(width: 14)
                    Text(prayer.name)
                        .font(.system(size: 11, weight: isActive ? .medium : .regular))
                        .foregroundColor(isActive ? accentGreen : .white.opacity(0.38))
                        .frame(width: 44, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 1)
                            if progress > 0 {
                                Rectangle()
                                    .fill(accentGreen.opacity(0.5))
                                    .frame(width: geo.size.width * progress, height: 1)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }

                    Text(entry.prayerTimes.time(for: prayer.key))
                        .font(.system(size: 12, weight: isActive ? .medium : .regular))
                        .foregroundColor(isActive ? .white.opacity(0.88) : .white.opacity(0.38))
                        .monospacedDigit()
                }
                .padding(.vertical, 2)
            }
        }
        .padding(8)
        .containerBackground(for: .widget) { bgColor }
    }

    // MARK: - Large

    var largeWidget: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Prayer Times")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.28))
                    .textCase(.uppercase)
                    .kerning(0.7)
                Spacer()
                Text(entry.locationName)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.22))
                Text("•")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.15))
                Text(entry.date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.22))
            }
            .padding(.bottom, 10)

            ForEach(prayers, id: \.key) { prayer in
                let isActive = prayer.key == currentPrayerKey
                let progress = progressForPrayer(key: prayer.key)

                HStack(spacing: 8) {
                    Image(systemName: iconForPrayer(prayer.key))
                        .font(.system(size: 10))
                        .foregroundColor(isActive ? accentGreen : .white.opacity(0.25))
                        .frame(width: 14)
                    Text(prayer.name)
                        .font(.system(size: 11, weight: isActive ? .medium : .regular))
                        .foregroundColor(isActive ? accentGreen : .white.opacity(0.35))
                        .frame(width: 44, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 2)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                            if progress > 0 {
                                Rectangle()
                                    .fill(accentGreen.opacity(0.35))
                                    .frame(width: geo.size.width * progress, height: 2)
                                    .clipShape(RoundedRectangle(cornerRadius: 2))
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }

                    Text(entry.prayerTimes.time(for: prayer.key))
                        .font(.system(size: 12, weight: isActive ? .medium : .regular))
                        .foregroundColor(isActive ? .white.opacity(0.88) : .white.opacity(0.35))
                        .monospacedDigit()
                }
                .padding(.vertical, 5)

                if prayer.key != prayers.last?.key {
                    Divider()
                        .overlay(Color.white.opacity(0.04))
                }
            }
        }
        .padding(10)
        .containerBackground(for: .widget) { bgColor }
    }
}

// MARK: - Widget Configuration

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PrayerWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    PrayerWidget()
} timeline: {
    PrayerEntry(date: .now, prayerTimes: WidgetPrayerTimes(fajr: "04:30", sunrise: "05:45", dhuhr: "12:30", asr: "15:45", maghrib: "18:30", isha: "20:00"), locationName: "Jakarta")
}

#Preview(as: .accessoryRectangular) {
    PrayerWidget()
} timeline: {
    PrayerEntry(date: .now, prayerTimes: WidgetPrayerTimes(fajr: "04:30", sunrise: "05:45", dhuhr: "12:30", asr: "15:45", maghrib: "18:30", isha: "20:00"), locationName: "Jakarta")
}
