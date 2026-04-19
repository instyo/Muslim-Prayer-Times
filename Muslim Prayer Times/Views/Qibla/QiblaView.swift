//
//  QiblaView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import SwiftUI
import CoreLocation

struct QiblaView: View {
    @ObservedObject var locationService: LocationService
    @StateObject private var viewModel = QiblaViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView("Finding Qibla direction...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            if let loc = locationService.location {
                                await viewModel.loadQiblaData(
                                    latitude: loc.coordinate.latitude,
                                    longitude: loc.coordinate.longitude
                                )
                            }
                        }
                    }

                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {

                            // MARK: - Header
                            VStack(alignment: .leading, spacing: 4) {
                                Text("PRECISION FINDER")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("AccentGold"))
                                    .tracking(2)

                                Text("Find the Path")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 32)

                            // MARK: - Compass
                            CompassView(
                                qiblaAngle: viewModel.qiblaRotationAngle
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 40)

                            // MARK: - Degrees & Distance
                            HStack(alignment: .bottom, spacing: 0) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DEGREES")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("AccentGold"))
                                        .tracking(2)

                                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                                        Text("\(Int(viewModel.qiblaDirection))°")
                                            .font(.system(size: 52, weight: .bold))

                                        Text(cardinalDirection(for: viewModel.qiblaDirection))
                                            .font(.system(size: 52, weight: .bold))
                                    }
                                    .foregroundColor(.primary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("DISTANCE")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("AccentGold"))
                                        .tracking(2)

                                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                                        Text(formattedDistance(viewModel.distanceKm))
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.primary)

                                        Text("km")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                            Divider()
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)

                            // MARK: - Precision Alignment Card
                            PrecisionAlignmentCard {
                                Task {
                                    if let loc = locationService.location {
                                        await viewModel.loadQiblaData(
                                            latitude: loc.coordinate.latitude,
                                            longitude: loc.coordinate.longitude
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            if let loc = locationService.location {
                await viewModel.loadQiblaData(
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude
                )
            }
        }
        .onAppear {
            viewModel.setLocationService(locationService)
            viewModel.startCompass()
        }
        .onDisappear { viewModel.stopCompass() }
    }

    // MARK: - Helpers

    private func cardinalDirection(for degrees: Double) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        return directions[index]
    }

    private func formattedDistance(_ km: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: km)) ?? "\(Int(km))"
    }
}

// MARK: - CompassView

struct CompassView: View {
    let qiblaAngle: Double

    var body: some View {
        ZStack {
            // Outer subtle ring
            Circle()
                .fill(Color.gray.opacity(0.08))
                .frame(width: 300, height: 300)

            // Inner ring
            Circle()
                .fill(Color.gray.opacity(0.05))
                .frame(width: 240, height: 240)

            // Tick marks
            ForEach(0..<36, id: \.self) { i in
                let angle = Double(i) * 10.0
                let isMajor = i % 9 == 0  // N, E, S, W positions

                Rectangle()
                    .fill(Color.gray.opacity(isMajor ? 0 : 0.25))
                    .frame(width: 1, height: isMajor ? 0 : 8)
                    .offset(y: -118)
                    .rotationEffect(.degrees(angle))
            }

            // Diagonal accent lines (corners) — subtle geometric detail
            ForEach([45.0, 135.0, 225.0, 315.0], id: \.self) { angle in
                Rectangle()
                    .fill(Color("AccentGold").opacity(0.4))
                    .frame(width: 1.5, height: 16)
                    .offset(y: -118)
                    .rotationEffect(.degrees(angle))
            }

            // Cardinal labels
            cardinalLabel("N", offset: CGPoint(x: 0, y: -130))
            cardinalLabel("S", offset: CGPoint(x: 0, y: 130))
            cardinalLabel("W", offset: CGPoint(x: -130, y: 0))
            cardinalLabel("E", offset: CGPoint(x: 130, y: 0))

            // Needle group — rotates together
            ZStack {
                // Gold needle (opposite / south end)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color("AccentGold").opacity(0.6), Color("AccentGold")],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 5, height: 100)
                    .offset(y: 30)   // points downward (away from Qibla)

                // Dark green needle (points toward Qibla)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color("PrimaryGreen"), Color("PrimaryGreen").opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 5, height: 110)
                    .offset(y: -40)   // points upward toward Qibla
            }
            .rotationEffect(.degrees(qiblaAngle))
            .animation(.easeInOut(duration: 0.15), value: qiblaAngle)

            // Center pivot dot
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.1), radius: 4)

                Circle()
                    .stroke(Color("PrimaryGreen"), lineWidth: 2)
                    .frame(width: 14, height: 14)

                Circle()
                    .fill(Color("PrimaryGreen"))
                    .frame(width: 5, height: 5)
            }

            // Mosque icon — rotates to show Qibla direction
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 52, height: 52)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

                    Image("kaaba")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                Spacer()
            }
            .frame(height: 300)
            .rotationEffect(.degrees(qiblaAngle))
            .animation(.easeInOut(duration: 0.15), value: qiblaAngle)
        }
        .frame(width: 300, height: 300)
    }

    @ViewBuilder
    private func cardinalLabel(_ text: String, offset: CGPoint) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.secondary)
            .offset(x: offset.x, y: offset.y)
    }
}

// MARK: - PrecisionAlignmentCard

struct PrecisionAlignmentCard: View {
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: "location.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Precision Alignment")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Ensure your device is flat for the most accurate calculation.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Refresh button
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
    }
}
