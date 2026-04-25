//
//  LocationPermissionView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//


import SwiftUI

struct LocationPermissionView: View {
    @ObservedObject var locationService: LocationService

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(Color("PrimaryGreen"))

            VStack(spacing: 8) {
                Text("Enable Location")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Precise location is needed to calculate accurate prayer times for your area.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                locationService.requestLocation()
            } label: {
                Text("Allow Location Access")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PrimaryGreen"))
                    .cornerRadius(14)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .background(Color("Background").ignoresSafeArea())
    }
}
