//
//  PrayerRowView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import SwiftUI

struct PrayerRowView: View {
    let item: PrayerItem
    private var isOngoing: Bool { item.status == .ongoing }

    var body: some View {
        HStack(spacing: 16) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(isOngoing ? Color("PrimaryGreen") : Color.gray.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName(for: item.name))
                    .foregroundColor(isOngoing ? .white : .gray)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .fontWeight(isOngoing ? .bold : .medium)
                    .foregroundColor(isOngoing ? .white : .primary)

                Text(item.status.label)
                    .font(.caption)
                    .foregroundColor(statusColor(for: item.status))
            }

            Spacer()

            Text(item.time)
                .font(.system(.body, design: .monospaced))
                .fontWeight(isOngoing ? .bold : .regular)
                .foregroundColor(isOngoing ? .white : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(isOngoing ? Color("PrimaryGreen") : Color.white)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func iconName(for prayer: String) -> String {
        switch prayer {
        case "Fajr": return "sunrise.fill"
        case "Sunrise": return "sun.horizon.fill"
        case "Dhuhr": return "sun.max.fill"
        case "Asr": return "sun.min.fill"
        case "Maghrib": return "sunset.fill"
        case "Isha": return "moon.stars.fill"
        default: return "clock.fill"
        }
    }

    private func statusColor(for status: PrayerStatus) -> Color {
        switch status {
        case .done: return .secondary
        case .ongoing: return .white.opacity(0.8)
        case .upcoming: return Color("AccentGold")
        case .later: return .secondary
        }
    }
}
