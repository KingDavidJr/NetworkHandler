//
//  URLProtocol.swift
//  NetworkHandler
//
//  Created by David Amedeka on 7/6/25.
//
import Foundation

public protocol NetworkHandlerURLProtocol {
    var url: URL? { get }
    var urlAsString: String? { get }
}
