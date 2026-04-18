//
//  PrayerTimeHelper.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//


import Foundation

struct PrayerTimeHelper {

    // Convert "13:10" string -> Date untuk hari ini
    static func timeStringToDate(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.calendar = Calendar.current

        guard let time = formatter.date(from: timeString) else { return nil }

        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(bySettingHour: components.hour ?? 0,
                             minute: components.minute ?? 0,
                             second: 0,
                             of: now)
    }

    // Determine status tiap prayer
    static func determinePrayerStatuses(from times: PrayerTimes) -> [PrayerItem] {
        let prayers: [(String, String)] = [
            ("Fajr", times.fajr),
            ("Sunrise", times.sunrise),
            ("Dhuhr", times.dhuhr),
            ("Asr", times.asr),
            ("Maghrib", times.maghrib),
            ("Isha", times.isha)
        ]

        let now = Date()
        var items: [PrayerItem] = []
        var currentIndex: Int? = nil

        let prayerDates = prayers.compactMap { (name, time) -> (String, String, Date)? in
            guard let date = timeStringToDate(time) else { return nil }
            return (name, time, date)
        }

        // Cari prayer yang sedang ongoing (waktu sekarang antara prayer ini dan prayer berikutnya)
        for i in 0..<prayerDates.count {
            let current = prayerDates[i]
            let nextDate = i + 1 < prayerDates.count ? prayerDates[i + 1].2 : nil

            if now >= current.2 {
                if let next = nextDate {
                    if now < next {
                        currentIndex = i
                    }
                } else {
                    currentIndex = i
                }
            }
        }

        for (i, (name, time, date)) in prayerDates.enumerated() {
            let status: PrayerStatus
            if let current = currentIndex {
                if i < current {
                    status = .done
                } else if i == current {
                    status = .ongoing
                } else {
                    status = .later
                }
            } else {
                status = date > now ? .upcoming : .done
            }
            items.append(PrayerItem(name: name, time: time, status: status))
        }

        return items
    }

    // Format remaining time ke string "1h 42m"
    static func remainingTime(until timeString: String) -> String {
        guard let target = timeStringToDate(timeString) else { return "" }
        let now = Date()
        let diff = target.timeIntervalSince(now)

        if diff <= 0 { return "" }

        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m remaining"
        } else {
            return "\(minutes)m remaining"
        }
    }

    // Cari prayer berikutnya setelah ongoing
    static func nextPrayer(items: [PrayerItem]) -> PrayerItem? {
        if let ongoingIndex = items.firstIndex(where: { $0.status == .ongoing }) {
            let nextIndex = ongoingIndex + 1
            if nextIndex < items.count {
                return items[nextIndex]
            }
        }
        return items.first(where: { $0.status == .upcoming })
    }
}