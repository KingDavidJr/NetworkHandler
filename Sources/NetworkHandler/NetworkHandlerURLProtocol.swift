//
//  URLProtocol.swift
//  NetworkHandler
//
//  Created by David Amedeka on 7/6/25.
//
import Foundation

protocol NetworkHandlerURLProtocol {
    var url: URL { get }
    init(url: URL)
}
