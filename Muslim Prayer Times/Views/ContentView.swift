//
//  ContentView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationService = LocationService()

    var body: some View {
        Group {
            switch locationService.authorizationStatus {
            case .notDetermined:
                LocationPermissionView(locationService: locationService)

            case .denied, .restricted:
                LocationDeniedView()

            case .authorizedWhenInUse, .authorizedAlways:
                if locationService.location != nil {
                    MainTabView(locationService: locationService)
                } else {
                    ProgressView("Getting your location...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("Background"))
                }

            @unknown default:
                LocationPermissionView(locationService: locationService)
            }
        }
        .onAppear {
            locationService.requestLocation()
        }
    }
}
