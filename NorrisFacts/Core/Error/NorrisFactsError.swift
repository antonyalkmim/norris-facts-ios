//
//  NorrisFactsError.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

enum NorrisFactsError: Error {
    case unknow
    case application(NorrisFactsErrorType)
    case network(NetworkError)
}

protocol NorrisFactsErrorType {
    var code: Int { get }
    var message: String { get }
}

extension NorrisFactsError: NorrisFactsErrorType {
    
    var code: Int {
        switch self {
        case .unknow: return 0
        case .application(let err): return err.code
        case .network(let err): return err.code
        }
    }
    
    var message: String {
        switch self {
        case .unknow: return "Unknow"
        case .application(let err): return err.message
        case .network(let err): return err.message
        }
    }
}

extension NorrisFactsError: LocalizedError {
    public var localizedDescription: String { self.message }
}

enum NetworkError: Error {
    case unknow(Error?)
    case jsonMapping(Error?)
    case connectionError
    case noInternetConnection
}

extension NetworkError: NorrisFactsErrorType {
    var code: Int { 1 }
    
    var message: String {
        switch self {
        case .unknow(let err): return err?.localizedDescription ?? "Unknow"
        case .jsonMapping(let err): return err?.localizedDescription ?? "Parser error"
        case .connectionError: return "Connection Error"
        case .noInternetConnection: return "No internet connection"
        }
    }
}

extension NetworkError: LocalizedError {
    public var localizedDescription: String { self.message }
}
