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
    
    /// get categories if there is no one on local database
    func syncFactsCategories() -> Single<Void>
    
    /// get facts saved on local database filtering by searchTerm
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]>
    
    /// search facts by searchTerm and save it locally
    func searchFacts(searchTerm: String) -> Observable<[NorrisFact]>
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
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        storage.getFacts(searchTerm: searchTerm)
    }
    
    func searchFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        Observable.just(searchTerm)
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] term -> Observable<[NorrisFact]> in
                guard let `self` = self else { return .empty() }

                return self.api.rx.request(.search(term: term))
                    .map(SearchFactResponse.self)
                    .map { $0.facts }
                    .asObservable()
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] facts in
                self?.storage.saveSearch(term: searchTerm, facts: facts)
            })
      }
    
}
