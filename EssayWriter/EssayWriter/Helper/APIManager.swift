//
//  APIManager.swift
//  EssayWriter
//
//  Created by Ruchi Sancheti on 12/07/25.
//

import Foundation

// MARK: - Network Error Types
enum NetworkError: Error {
    case badURL
    case invalidRequest
    case badResponse
    case badStatus(Int)
    case failedToDecodeResponse(Error)
}

// MARK: - API Manager
final class APIManager {

    static let shared = APIManager()

    private init() {}

    /// Perform a GET request and decode response to a Codable type.
    func getData<T: Codable>(fromURL urlString: String) async -> Result<T, NetworkError> {
        guard let url = URL(string: urlString) else {
            return .failure(.badURL)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.badResponse)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                return .failure(.badStatus(httpResponse.statusCode))
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return .success(decodedData)
            } catch {
                return .failure(.failedToDecodeResponse(error))
            }

        } catch {
            return .failure(.invalidRequest)
        }
    }

    /// Perform a POST request and decode response to a Decodable type.
    func getPostData<T: Decodable>(fromURL urlString: String) async -> Result<T, NetworkError> {
        guard let url = URL(string: urlString) else {
            return .failure(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? 500
                return .failure(.badStatus(status))
            }

            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedData)

        } catch {
            return .failure(.failedToDecodeResponse(error))
        }
    }
}
