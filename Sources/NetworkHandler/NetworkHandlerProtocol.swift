//
//  NetworkHandlerProtocol.swift
//  NetworkHandler
//
//  Created by David Amedeka on 7/6/25.
//

import Foundation

public protocol NetworkHandlerProtocol {
    @available(iOS 15.0, macOS 12.0, *) func fetchData(url: URL, httpMethod: NetworkHandler.HTTPMethod, header: [String: String]?) async throws -> Data?
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func encode<T: Encodable>(_ value: T) throws -> Data
    @available(iOS 15.0, macOS 12.0, *)func fetchDataAndDecode<T: Decodable>(url: URL, httpMethod: NetworkHandler.HTTPMethod, header: [String: String]?, as type: T.Type) async throws -> T
}
