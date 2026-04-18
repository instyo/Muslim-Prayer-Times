//
//  QiblaModel.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import Foundation

struct QiblaInfo: Codable {
    let direction: QiblaDirection
    let distance: QiblaDistance
}

struct QiblaDirection: Codable {
    let degrees: Double
    let from: String
    let clockwise: Bool
}

struct QiblaDistance: Codable {
    let value: Double
    let unit: String
}
