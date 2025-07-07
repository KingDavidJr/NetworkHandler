// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class NetworkHandler: NetworkHandlerProtocol, Sendable {
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case decodingError(Error)
        case httpError(statusCode: Int, response: URLResponse)
        case requestFailed(Error)
        case otherError(Error)
    }
    
    public init() {}
    
    @available(macOS 12.0, *)
    public func fetchData(from url: URL, with headers: [String: String] = [:]) async throws -> Data? {
        do {
            guard url != URL("") else {
                throw NetworkError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if headers != [:] {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, response: response)
                }
                return data
            }
        } catch let urlError as URLError {
            throw NetworkError.requestFailed(urlError)
        } catch  {
            throw NetworkError.requestFailed(error)
        }
        return nil
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        return try JSONEncoder().encode(value)
    }
}

extension NetworkHandler {
    @available(macOS 12.0, *)
    public func fetchDataAndDecode<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        guard let data = try await fetchData(from: url) else {
            throw NetworkError.otherError(NSError(domain: "NetworkHandler", code: 1001, userInfo: [NSLocalizedDescriptionKey : "No data returned from URL"]))
        }
        return try decode(type, from: data)
    }
}
