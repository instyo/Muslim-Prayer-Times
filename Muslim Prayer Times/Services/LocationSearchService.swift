//
//  LocationSearchService.swift
//  Muslim Prayer Times
//
//  Created by Ikhwan Setyo on 25/04/26.
//

import Foundation
import Combine

class LocationSearchService: ObservableObject {
    @Published var results: [LocationSearchResult] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var searchTask: Task<Void, Never>?
    private let baseURL = "https://nominatim.openstreetmap.org/search"

    func search(query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            isLoading = false
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        searchTask = Task {
            do {
                let fetched = try await performSearch(query: trimmed)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.results = fetched
                    self.isLoading = false
                    if fetched.isEmpty {
                        self.errorMessage = "No locations found. Try a different search."
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.isLoading = false
                    self.results = []
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func performSearch(query: String) async throws -> [LocationSearchResult] {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "jsonv2"),
            URLQueryItem(name: "limit", value: "5")
        ]

        guard let url = components?.url else {
            throw LocationSearchError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("MuslimPrayerTimes/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LocationSearchError.requestFailed
        }

        do {
            return try JSONDecoder().decode([LocationSearchResult].self, from: data)
        } catch {
            throw LocationSearchError.decodingFailed
        }
    }
}

enum LocationSearchError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid search URL."
        case .requestFailed: return "Network request failed. Check your internet connection."
        case .decodingFailed: return "Failed to parse search results."
        }
    }
}