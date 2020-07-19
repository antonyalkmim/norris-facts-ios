//
//  NorrisFactsError.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

protocol NorrisFactsErrorType: LocalizedError {
    var code: Int { get }
    var message: String { get }
}

extension NorrisFactsErrorType {
    public var localizedDescription: String { self.message }
}

enum NorrisFactsError: Error {
    case unknow(Error?)
    case application(NorrisFactsErrorType)
    case network(NetworkError)
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

enum NetworkError: NorrisFactsErrorType, LocalizedError {
    case unknow(Error?)
    case jsonMapping(Error?)
    case connectionError
    case noInternetConnection
    case statusCodeError(Int)
    
    var code: Int {
        switch self {
        case .unknow: return 0
        case .jsonMapping: return 1
        case .connectionError: return 2
        case .noInternetConnection: return 3
        case .statusCodeError: return 4
        }
    }
    
    var message: String {
        switch self {
        case .unknow(let err): return err?.localizedDescription ?? "Unknow"
        case .jsonMapping(let err): return err?.localizedDescription ?? "Parser error"
        case .connectionError: return "Connection Error"
        case .noInternetConnection: return "No internet connection"
        case .statusCodeError(let statusCode): return "Status code error \(statusCode)"
        }
    }
}

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.code == rhs.code
    }
}
