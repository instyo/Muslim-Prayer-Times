//
//  LocationService.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import Foundation
import CoreLocation
import Combine

enum LocationError: Error, LocalizedError {
    case denied
    case restricted
    case unknown

    var errorDescription: String? {
        switch self {
        case .denied:
            return "Location access denied. Please enable it in Settings to get accurate prayer times."
        case .restricted:
            return "Location access is restricted on this device."
        case .unknown:
            return "Unable to determine your location."
        }
    }
}

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let appGroupID = "group.insaneworks.space.MuslimPrayerTimes"

    @Published var location: CLLocation?
    @Published var locationError: LocationError?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var cityName: String = ""
    @Published var heading: Double = 0

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            manager.requestLocation()
            manager.startUpdatingHeading()
        case .denied:
            locationError = .denied
        case .restricted:
            locationError = .restricted
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy >= 0 {
            heading = newHeading.magneticHeading
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        if let loc = locations.first {
            saveLocationToAppGroup(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
            fetchCityName(from: loc)
        }
    }

    private func saveLocationToAppGroup(lat: Double, lon: Double) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let locationData: [String: Any] = [
            "latitude": lat,
            "longitude": lon,
            "cityName": cityName
        ]
        defaults.set(locationData, forKey: "userLocation")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = .unknown
    }

    private func fetchCityName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self?.cityName = city
                    self?.saveCityNameToAppGroup(city)
                }
            }
        }
    }

    private func saveCityNameToAppGroup(_ cityName: String) {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              var locationData = defaults.dictionary(forKey: "userLocation") as? [String: Any] else { return }
        locationData["cityName"] = cityName
        defaults.set(locationData, forKey: "userLocation")
    }
}
