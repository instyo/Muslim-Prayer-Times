//
//  CurrentPrayerCard.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import SwiftUI

struct CurrentPrayerCard: View {
    let currentPrayer: PrayerItem
    let nextPrayer: PrayerItem
    let remainingTime: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CURRENT PRAYER")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AccentGold"))
                        .tracking(1.5)

                    Text(currentPrayer.name)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("PrimaryGreen"))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("ENDS AT")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tracking(1)

                    Text(nextPrayer.time)
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            // Progress bar — simplified, static untuk sekarang
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color("PrimaryGreen"))
                        .frame(width: geo.size.width * 0.55, height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                Text(remainingTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // Next prayer badge
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text("NEXT: \(nextPrayer.name.uppercased())")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color("AccentGold").opacity(0.15))
                .foregroundColor(Color("AccentGold"))
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}
