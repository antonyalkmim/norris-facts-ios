//
//  NorrisFactServiceMock.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 18/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift
@testable import NorrisFacts

class NorrisFactsServiceMocked: NorrisFactsServiceType {
    
    var syncFactsCategoriesResult: Observable<Void> = .just(())
    var getFactsResult: [String: Observable<[NorrisFact]>] = ["": .just([])]
    var searchFactsResult: Observable<[NorrisFact]> = .just([])
    var getCategoriesResult: Observable<[FactCategory]> = .just([])
    var getPastSearchTermsResult: Observable<[String]> = .just([])
    
    func syncFactsCategories() -> Observable<Void> {
        syncFactsCategoriesResult
    }
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        getFactsResult[searchTerm] ?? .just([])
    }
    
    func searchFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        searchFactsResult
    }
    
    func getFactCategories() -> Observable<[FactCategory]> {
        getCategoriesResult
    }
    
    func getPastSearchTerms() -> Observable<[String]> {
        getPastSearchTermsResult
    }
}
