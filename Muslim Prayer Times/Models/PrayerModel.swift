//
//  PrayerModel.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import Foundation

struct MainResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerResponse
}

struct PrayerResponse: Codable {
    let times: PrayerTimes
    let date: PrayerDate
    let qibla: QiblaInfo
    let timezone: TimezoneInfo
}

struct PrayerTimes: Codable {
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

struct PrayerDate: Codable {
    let readable: String
    let hijri: HijriDate
    let gregorian: GregorianDate
}

struct HijriDate: Codable {
    let date: String
    let day: String
    let month: HijriMonth
    let year: String
}

struct HijriMonth: Codable {
    let number: Int
    let en: String
}

struct GregorianDate: Codable {
    let date: String
    let day: String
    let month: GregorianMonth
    let year: String
}

struct GregorianMonth: Codable {
    let number: Int
    let en: String
}

struct TimezoneInfo: Codable {
    let name: String
    let utcOffset: String
    let abbreviation: String

    enum CodingKeys: String, CodingKey {
        case name
        case utcOffset = "utc_offset"
        case abbreviation
    }
}

// Prayer item untuk ditampilkan di list
struct PrayerItem: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    var status: PrayerStatus
}

enum PrayerStatus {
    case done
    case ongoing
    case upcoming
    case later

    var label: String {
        switch self {
        case .done: return "DONE"
        case .ongoing: return "ONGOING"
        case .upcoming: return "UPCOMING"
        case .later: return "Later Today"
        }
    }
}
