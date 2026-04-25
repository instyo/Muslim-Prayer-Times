//
//  LocationSearchView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 25/04/26.
//

import SwiftUI
import CoreLocation

struct LocationSearchView: View {
    @StateObject private var searchService = LocationSearchService()
    @ObservedObject var locationService: LocationService
    @State private var searchText = ""

    var onLocationSelected: (() -> Void)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if searchService.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                        .foregroundColor(.secondary)
                    Spacer()
                } else if let error = searchService.errorMessage, searchService.results.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else if searchService.results.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 48))
                            .foregroundColor(Color("PrimaryGreen"))
                        Text("Search for your city")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("Enter a city name to get prayer times for that location.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Spacer()
                } else {
                    List(searchService.results) { result in
                        Button {
                            selectResult(result)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.name)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text(result.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }

                VStack(spacing: 12) {
                    Divider()

                    if locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways {
                        Button {
                            locationService.useCurrentLocation()
                            onLocationSelected?()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                Text("Use Current Location")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("PrimaryGreen"))
                            .cornerRadius(14)
                            .padding(.horizontal)
                        }
                    }

                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "gear")
                            Text("Enable Location in Settings")
                        }
                        .font(.subheadline)
                        .foregroundColor(Color("PrimaryGreen"))
                    }
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("Select City")
            .searchable(text: $searchText, prompt: "Search city name...")
            .onChange(of: searchText) { _, newValue in
                searchService.search(query: newValue)
            }
            .background(Color("Background").ignoresSafeArea())
        }
    }

    private func selectResult(_ result: LocationSearchResult) {
        guard let coordinate = result.coordinate else { return }
        locationService.setManualLocation(
            lat: coordinate.latitude,
            lon: coordinate.longitude,
            cityName: result.name
        )
        onLocationSelected?()
    }
}