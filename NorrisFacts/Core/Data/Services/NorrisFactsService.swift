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
    func syncFactsCategories() -> Single<Void>
    func getFacts(limit: Int) -> Observable<[NorrisFact]>
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
    
    func syncFactsCategories() -> Single<Void> {
        let syncCategories = api.rx.request(.getCategories)
            .map([FactCategory].self)
            .observeOn(MainScheduler.instance)
            .flatMap { [weak self] remoteCategories -> Single<Void> in
                guard let `self` = self else { return .never() }
                self.storage.saveCategories(remoteCategories)
                return .just(())
            }
        
        return storage.getCategories()
            .filter { $0.isEmpty }
            .asObservable()
            .flatMap {
                $0.isEmpty ? syncCategories : .just(())
            }
            .asSingle()
    }
    
    func getFacts(limit: Int) -> Observable<[NorrisFact]> {
        .just([])
    }
    
}
