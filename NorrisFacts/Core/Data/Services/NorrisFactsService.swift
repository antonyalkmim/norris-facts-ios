//
//  NorrisFactsService.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

protocol NorrisFactsServiceType {
    func searchFacts(term: String)
}

class NorrisFactsService: NorrisFactsServiceType {
    
    var api: HttpService<NorrisFactsAPI> = HttpService<NorrisFactsAPI>()
//    var storage: NorrisStorageStorage = NorrisStorageStorage()
    
    init(
        api: HttpService<NorrisFactsAPI> = HttpService<NorrisFactsAPI>()
    ) {
        self.api = api
    }
    
    func searchFacts(term: String) {
        api.request(NorrisFactsAPI.search(term: term)) { result in
            print(result)
        }
    }
}
