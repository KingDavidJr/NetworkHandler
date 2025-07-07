//
//  NetworkHandlerProtocol.swift
//  NetworkHandler
//
//  Created by David Amedeka on 7/6/25.
//

import Foundation

public protocol NetworkHandlerProtocol {
    @available(macOS 12.0, *) func fetchData(from url: URL, with headers: [String: String]) async throws -> Data?
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func encode<T: Encodable>(_ value: T) throws -> Data
}
