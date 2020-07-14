//
//  FactListError.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 14/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

enum FactListError: Error {
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
}
