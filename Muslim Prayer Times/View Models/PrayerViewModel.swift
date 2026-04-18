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
    @Published var progress: Double = 0

    private var timer: AnyCancellable?

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
            calculateProgress()
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func startCountdownTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.calculateProgress()
            }
    }

    func stopCountdownTimer() {
        timer?.cancel()
        timer = nil
    }

    func remainingTime(for prayer: PrayerItem) -> String {
        return PrayerTimeHelper.remainingTime(until: prayer.time)
    }

    func calculateProgress() {
        guard let current = currentPrayer, let next = nextPrayer else {
            progress = 0
            return
        }
        progress = PrayerTimeHelper.progressPercentage(currentTime: current.time, nextTime: next.time)
    }
}
