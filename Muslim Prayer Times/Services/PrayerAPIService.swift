//
//  PrayerAPIService.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 18/04/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL."
        case .requestFailed: return "Network request failed. Check your internet connection."
        case .decodingFailed: return "Failed to parse prayer data."
        case .serverError(let code): return "Server error with code \(code)."
        }
    }
}

class PrayerAPIService {
    static let shared = PrayerAPIService()
    private init() {}
    
    func fetchPrayerData(latitude: Double, longitude: Double) async throws -> PrayerResponse {
        let urlString = "https://islamicapi.com/api/v1/prayer-time/?lat=\(latitude)&lon=\(longitude)&api_key=YOUR_API_KEY_HERE"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add headers here
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoded = try JSONDecoder().decode(MainResponse.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingFailed
        }
    }
}
