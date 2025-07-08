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
    
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    public init() {}
    
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchData(url: URL, httpMethod: HTTPMethod, header: [String: String]? = nil) async throws -> Data? {
        do {
            guard url != URL("") else {
                throw NetworkError.invalidURL
            }
            var request = createRequest(url: url, httpMethod: httpMethod, header: header)
            
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode, response: response)
                }
                return data
            } else {
                throw NetworkError.invalidResponse
            }
        } catch let urlError as URLError {
            throw NetworkError.requestFailed(urlError)
        } catch  {
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        return try JSONEncoder().encode(value)
    }
    
    func createRequest(url: URL, httpMethod: HTTPMethod, header: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let header = header {
            guard !header.isEmpty else { return request }
            request = addHeaders(request: request, headers: header)
        }
        
        return request
    }
    
    func addHeaders(request: URLRequest, headers: [String: String]) -> URLRequest {
        var request = request
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

extension NetworkHandler {
    @available(iOS 15.0, macOS 12.0, *)
    public func fetchDataAndDecode<T: Decodable>(url: URL, httpMethod: HTTPMethod, header: [String: String]?, as type: T.Type) async throws -> T {
        guard let data = try await fetchData(url: url, httpMethod: httpMethod, header: header) else {
            throw NetworkError.otherError(NSError(domain: "NetworkHandler", code: 1001, userInfo: [NSLocalizedDescriptionKey : "No data returned from URL"]))
        }
        return try decode(type, from: data)
    }
}
