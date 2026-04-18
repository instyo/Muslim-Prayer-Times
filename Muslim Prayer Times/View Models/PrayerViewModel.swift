//
//  PrayerViewModel.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class PrayerViewModel: ObservableObject {
    @Published var prayerItems: [PrayerItem] = []
    @Published var currentPrayer: PrayerItem?
    @Published var nextPrayer: PrayerItem?
    @Published var hijriDateString: String = ""
    @Published var readableDate: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var refreshTimer: Timer?

    func fetchPrayerTimes(latitude: Double, longitude: Double, showLoading: Bool = true) async {
        isLoading = showLoading
        errorMessage = nil

        do {
            let response = try await PrayerAPIService.shared.fetchPrayerData(
                latitude: latitude,
                longitude: longitude
            )
            let items = PrayerTimeHelper.determinePrayerStatuses(from: response.times)
            self.prayerItems = items
            self.currentPrayer = items.first(where: { $0.status == .ongoing })
            self.nextPrayer = PrayerTimeHelper.nextPrayer(items: items)

            let h = response.date.hijri
            self.hijriDateString = "\(h.day) \(h.month.en) \(h.year) AH"
            self.readableDate = response.date.readable
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func startAutoRefresh(latitude: Double, longitude: Double) {
        // Refresh setiap 1 menit untuk update countdown
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchPrayerTimes(latitude: latitude, longitude: longitude, showLoading: false)
            }
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func remainingTime(for prayer: PrayerItem) -> String {
        return PrayerTimeHelper.remainingTime(until: prayer.time)
    }
}
