//
//  LocationSearchResult.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 25/04/26.
//

import Foundation
import CoreLocation

struct LocationSearchResult: Codable, Identifiable {
    let placeId: Int
    let licence: String
    let osmType: String
    let osmId: Int
    let lat: String
    let lon: String
    let category: String
    let type: String
    let placeRank: Int
    let importance: Double
    let addresstype: String
    let name: String
    let displayName: String
    let boundingbox: [String]

    var id: Int { placeId }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = Double(lat), let longitude = Double(lon) else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case licence
        case osmType = "osm_type"
        case osmId = "osm_id"
        case lat, lon
        case category, type
        case placeRank = "place_rank"
        case importance
        case addresstype
        case name
        case displayName = "display_name"
        case boundingbox
    }
}