//
//  PrayerView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import SwiftUI
import CoreLocation

struct PrayerView: View {
    @ObservedObject var locationService: LocationService
    @StateObject private var viewModel = PrayerViewModel()
    @State private var showingLocationSearch = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Button {
                                    showingLocationSearch = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "location.fill")
                                            .font(.caption)
                                            .foregroundColor(Color("PrimaryGreen"))
                                        Text(locationService.cityName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if !viewModel.hijriDateString.isEmpty {
                                    Text(viewModel.hijriDateString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            if let error = viewModel.errorMessage {
                                ErrorView(message: error) {
                                    Task {
                                        if let loc = locationService.location {
                                            await viewModel.fetchPrayerTimes(
                                                latitude: loc.coordinate.latitude,
                                                longitude: loc.coordinate.longitude
                                            )
                                        }
                                    }
                                }
                            } else {
                                // Current Prayer Card
                                if let current = viewModel.currentPrayer,
                                   let next = viewModel.nextPrayer {
                                    CurrentPrayerCard(
                                        currentPrayer: current,
                                        nextPrayer: next,
                                        remainingTime: viewModel.remainingTime(for: next),
                                        progress: viewModel.progress
                                    )
                                }

                                // Today's sequence
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("TODAY'S SEQUENCE")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color("AccentGold"))
                                            .tracking(1.5)

                                        Spacer()

                                        Text(viewModel.readableDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)

                                    ForEach(viewModel.prayerItems) { item in
                                        PrayerRowView(item: item)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            if let loc = locationService.location {
                await viewModel.fetchPrayerTimes(
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude
                )
            }
        }
        .onAppear {
            if locationService.location != nil {
                viewModel.startCountdownTimer()
            }
        }
        .onDisappear {
            viewModel.stopCountdownTimer()
        }
        .sheet(isPresented: $showingLocationSearch) {
            LocationSearchView(locationService: locationService) {
                showingLocationSearch = false
                if let loc = locationService.location {
                    Task {
                        await viewModel.fetchPrayerTimes(
                            latitude: loc.coordinate.latitude,
                            longitude: loc.coordinate.longitude
                        )
                    }
                }
            }
        }
        .onChange(of: locationService.location) { _, newLocation in
            if let loc = newLocation {
                Task {
                    await viewModel.fetchPrayerTimes(
                        latitude: loc.coordinate.latitude,
                        longitude: loc.coordinate.longitude
                    )
                }
            }
        }
    }
}
