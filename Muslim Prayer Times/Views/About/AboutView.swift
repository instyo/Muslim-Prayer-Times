//
//  AboutView.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // MARK: - App Icon
                        ZStack {
                            Circle()
                                .fill(Color("PrimaryGreen").opacity(0.1))
                                .frame(width: 120, height: 120)

                            Image("kaaba")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        }
                        .padding(.top, 40)

                        // MARK: - App Name
                        VStack(spacing: 8) {
                            Text("Muslim Prayer Times")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // MARK: - Description
                        VStack(alignment: .leading, spacing: 16) {
                            DescriptionRow(
                                icon: "heart.fill",
                                title: "Free to Use",
                                description: "This app is completely free for everyone. No subscriptions, no hidden fees."
                            )

                            DescriptionRow(
                                icon: "lasso.badge.sparkles",
                                title: "Open Source",
                                description: "This app is open source. Contributions and improvements are welcome."
                            )
                            
                            DescriptionRow(
                                icon: "photo",
                                title: "Attribution",
                                description: "icons created by Freepik - Flaticon"
                            )
                        }
                        .padding(.horizontal, 24)

                        Spacer()

                        // MARK: - GitHub Link
                        VStack(spacing: 12) {
                            Text("View Source Code")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button(action: {
                                if let url = URL(string: "https://github.com/instyo/Muslim-Prayer-Times") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                        .font(.system(size: 14))

                                    Text("GitHub Repository")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("PrimaryGreen"))
                                )
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - DescriptionRow

struct DescriptionRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("PrimaryGreen").opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color("PrimaryGreen"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}
