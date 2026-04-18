//
//  QiblaViewModel.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//


import Foundation
import CoreLocation
import Combine
import CoreMotion

@MainActor
class QiblaViewModel: ObservableObject {
    @Published var qiblaDirection: Double = 0
    @Published var distanceKm: Double = 0
    @Published var compassHeading: Double = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let motionManager = CMMotionManager()

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

    func startCompass() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            // Heading dari device dalam derajat
            let heading = -motion.attitude.yaw * (180 / .pi)
            DispatchQueue.main.async {
                self?.compassHeading = heading
            }
        }
    }

    func stopCompass() {
        motionManager.stopDeviceMotionUpdates()
    }

    // Sudut jarum qibla relatif terhadap orientasi device
    var qiblaRotationAngle: Double {
        return qiblaDirection + compassHeading
    }
}