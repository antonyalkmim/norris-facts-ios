//
//  FactListError.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 14/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

enum FactListError: Error, NorrisFactsErrorType {
    
    case syncCategories(Error)
    case loadFacts(Error)
    
    var error: NorrisFactsErrorType {
        switch self {
        case let .syncCategories(syncError):
            return (syncError as? NorrisFactsErrorType) ?? NorrisFactsError.unknow(syncError)
        case let .loadFacts(loadError):
            return (loadError as? NorrisFactsErrorType) ?? NorrisFactsError.unknow(loadError)
        }
    }
    
    var code: Int {
        switch self {
        case .syncCategories: return 5
        case .loadFacts: return 6
        }
    }
    
    var message: String {
        switch self {
        case .syncCategories: return "Error syncCategories"
        case .loadFacts: return "Error load facts"
        }
    }
    
}

extension FactListError: Equatable {
    static func == (lhs: FactListError, rhs: FactListError) -> Bool {
        lhs.code == rhs.code
    }
}
