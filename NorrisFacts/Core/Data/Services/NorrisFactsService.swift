//
//  NorrisFactsService.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift

protocol NorrisFactsServiceType {
    func searchFacts(term: String) -> Single<String>
}

class NorrisFactsService: NorrisFactsServiceType {
    
    var api: HttpService<NorrisFactsAPI>
    var storage: NorrisFactsStorageType
    
    init(
        api: HttpService<NorrisFactsAPI> = HttpService<NorrisFactsAPI>(),
        storage: NorrisFactsStorageType = NorrisFactsStorage()
    ) {
        self.api = api
        self.storage = storage
    }
    
    func searchFacts(term: String) -> Single<String> {
        api.rx.request(.search(term: term)).map { _ in "" }
    }
}
