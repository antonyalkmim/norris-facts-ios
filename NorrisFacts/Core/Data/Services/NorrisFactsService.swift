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
    func syncFactsCategories() -> Observable<Void>
    
    /// get facts categories saved on local database
    func getFactCategories() -> Observable<[FactCategory]>
    
    /// get facts saved on local database filtering by searchTerm
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]>
    
    /// search facts by searchTerm and save it locally
    func searchFacts(searchTerm: String) -> Observable<[NorrisFact]>
    
    // get unique past searches terms sorted by date
    func getPastSearchTerms() -> Observable<[String]>
}

class NorrisFactsService: NorrisFactsServiceType {
    
    let api: HttpService<NorrisFactsAPI>
    let storage: NorrisFactsStorageType
    let scheduler: SchedulerType?
    
    init(
        api: HttpService<NorrisFactsAPI> = HttpService<NorrisFactsAPI>(),
        storage: NorrisFactsStorageType = NorrisFactsStorage(),
        scheduler: SchedulerType? = nil
    ) {
        self.api = api
        self.storage = storage
        self.scheduler = scheduler
    }
    
    func syncFactsCategories() -> Observable<Void> {
        storage.getCategories()
            .flatMapLatest { [weak self] categories -> Observable<[FactCategory]> in
                guard let `self` = self else { return .never() }
                guard categories.isEmpty else { return .just([]) }
                
                return self.api.rx.request(.getCategories)
                    .map([FactCategory].self)
                    .observeOn(self.scheduler ?? MainScheduler.asyncInstance)
                    .retryWhen(
                        networkError: .connectionError,
                        maxRetries: 2,
                        retryAfter: .seconds(4),
                        scheduler: self.scheduler ?? MainScheduler.asyncInstance
                    )
                    .observeOn(self.scheduler ?? MainScheduler.instance)
                    .do(onSuccess: { [weak self] remoteCategories in
                        guard let `self` = self else { return }
                        self.storage.saveCategories(remoteCategories)
                    })
                    .asObservable()
            }
            .mapToVoid()
    }
    
    func getFactCategories() -> Observable<[FactCategory]> {
        storage.getCategories()
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
                    .observeOn(self.scheduler ?? MainScheduler.asyncInstance)
                    .retryWhen(
                        networkError: .connectionError,
                        maxRetries: 2,
                        retryAfter: .seconds(4),
                        scheduler: self.scheduler ?? MainScheduler.asyncInstance
                    )
                    .map { $0.facts }
                    .asObservable()
            }
            .observeOn(self.scheduler ?? MainScheduler.instance)
            .do(onNext: { [weak self] facts in
                self?.storage.saveSearch(term: searchTerm, facts: facts)
            })
    }
    
    func getPastSearchTerms() -> Observable<[String]> {
        storage.getPastSearchTerms()
    }
    
}
