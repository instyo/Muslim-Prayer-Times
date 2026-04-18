//
//  QiblaViewModel.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//


import Foundation
import CoreLocation
import Combine

@MainActor
class QiblaViewModel: ObservableObject {
    @Published var qiblaDirection: Double = 0
    @Published var distanceKm: Double = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    weak var locationService: LocationService?

    func loadQiblaData(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await PrayerAPIService.shared.fetchPrayerData(
                latitude: latitude,
                longitude: longitude
            )
            self.qiblaDirection = response.qibla.direction.degrees
            self.distanceKm = response.qibla.distance.value
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func setLocationService(_ service: LocationService) {
        self.locationService = service
    }

    func startCompass() {
        guard let service = locationService else { return }
        service.$heading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func stopCompass() {
        cancellables.removeAll()
    }

    var qiblaRotationAngle: Double {
        guard let service = locationService else { return qiblaDirection }
        return qiblaDirection - service.heading
    }
}