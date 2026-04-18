//
//  MainTabView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//


import SwiftUI

struct MainTabView: View {
    @ObservedObject var locationService: LocationService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PrayerView(locationService: locationService)
                .tabItem {
                    Label("Prayer", systemImage: "clock.fill")
                }
                .tag(0)

            QiblaView(locationService: locationService)
                .tabItem {
                    Label("Qibla", systemImage: "location.north.fill")
                }
                .tag(1)
        }
        .accentColor(Color("PrimaryGreen"))
    }
}