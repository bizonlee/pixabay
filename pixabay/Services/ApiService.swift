//
//  ApiService.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 25.03.2025.
//

import Foundation

enum ImageSearchError: Error {
    case invalidURL, requestFailed(Error), invalidResponse, decodingError
}

protocol ApiServiceProtocol {
    func searchImages(query: String, perPage: Int, completion: @escaping (Result<[PixabayImage], ImageSearchError>) -> Void)
}

class ApiService: ApiServiceProtocol {
    private let baseURL = URL(string: "https://pixabay.com/api/")!
    private let apiKey = "49512417-806812cc3434cd6d75f6875c8"

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    func searchImages(query: String, perPage: Int = 10, completion: @escaping (Result<[PixabayImage], ImageSearchError>) -> Void) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.invalidURL))
            return
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: queryEncoded),
            URLQueryItem(name: "safesearch", value: "true"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decodedData = try self.jsonDecoder.decode(PixabayResponse.self, from: data)
                completion(.success(decodedData.hits))
            } catch {
                completion(.failure(.decodingError))
            }
        }

        task.resume()
    }
}
