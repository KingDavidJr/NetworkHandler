// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public final class NetworkHandler: NetworkHandlerProtocol, Sendable {
    public enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case decodingError(Error)
        case httpError(statusCode: Int, response: URLResponse)
        case requestFailed(Error)
        case otherError(Error)
    }
    
    public init() {}
    
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchData(from url: URL, with headers: [String: String] = [:]) async throws -> Data? {
        print("NetworkHandler Debug: fetchData called for URL: \(url.absoluteString)") // Added
        do {
            guard url != URL("") else {
                print("NetworkHandler Debug: ERROR - Invalid URL passed: \(url.absoluteString)") // Added
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
            
            print("NetworkHandler Debug: Starting URLSession data task...") // Added
            let (data, response) = try await URLSession.shared.data(for: request)
            print("NetworkHandler Debug: URLSession data task completed.") // Added

            if let httpResponse = response as? HTTPURLResponse {
                print("NetworkHandler Debug: Received HTTP Status Code: \(httpResponse.statusCode)") // Added
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("NetworkHandler Debug: ERROR - HTTP Error: \(httpResponse.statusCode)") // Added
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, response: response)
                }
                print("NetworkHandler Debug: Data length: \(data.count) bytes") // Added
                return data
            } else {
                print("NetworkHandler Debug: ERROR - Invalid response type (not HTTPURLResponse).") // Added
                throw NetworkError.invalidResponse
            }
        } catch let urlError as URLError {
            print("NetworkHandler Debug: Caught URLError: \(urlError.localizedDescription) (Code: \(urlError.code.rawValue))") // Added
            throw NetworkError.requestFailed(urlError)
        } catch  {
            print("NetworkHandler Debug: Caught generic error: \(error.localizedDescription)") // Added
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        return try JSONEncoder().encode(value)
    }
}

extension NetworkHandler {
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchDataAndDecode<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
        guard let data = try await fetchData(from: url) else {
            throw NetworkError.otherError(NSError(domain: "NetworkHandler", code: 1001, userInfo: [NSLocalizedDescriptionKey : "No data returned from URL"]))
        }
        return try decode(type, from: data)
    }
}
