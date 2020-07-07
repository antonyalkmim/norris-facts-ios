//
//  FactsListViewModel.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift

protocol FactsListViewModelInput {
    var syncCategories: AnyObserver<Void> { get }
}

protocol FactsListViewModelOutput {
    var isLoading: ActivityIndicator { get }
    var errorViewModel: Observable<FactListErrorViewModel> { get }
}

protocol FactsListViewModelType {
    var inputs: FactsListViewModelInput { get }
    var outputs: FactsListViewModelOutput { get }
}

final class FactsListViewModel: FactsListViewModelType, FactsListViewModelInput, FactsListViewModelOutput {
    
    var inputs: FactsListViewModelInput { self }
    var outputs: FactsListViewModelOutput { self }
    
    // MARK: - Dependencies
    
    let factsService: NorrisFactsServiceType
    
    // MARK: - RX Inputs
    
    var syncCategories: AnyObserver<Void>
    
    // MARK: - RX Outputs
    
    var isLoading: ActivityIndicator
    var errorViewModel: Observable<FactListErrorViewModel>
    
    init(factsService: NorrisFactsServiceType = NorrisFactsService()) {
        self.factsService = factsService
        
        let _isLoading = ActivityIndicator()
        self.isLoading = _isLoading
        
        let syncCategoriesSubject = PublishSubject<Void>()
        self.syncCategories = syncCategoriesSubject.asObserver()
        
        let syncFactsCategoriesErrorViewModel = syncCategoriesSubject
            .asObservable()
            .flatMapLatest {
                factsService.syncFactsCategories()
                    .trackActivity(_isLoading)
                    .asObservable()
                    .materialize()
            }
            .errors()
            .map { error -> NorrisFactsErrorType in
                let err = (error as? NorrisFactsErrorType) ?? NorrisFactsError.unknow(error)
                return err
            }
            .map {
                FactListErrorViewModel(error: $0, isRetryEnabled: true)
            }
        
        self.errorViewModel = syncFactsCategoriesErrorViewModel
    }
}

struct FactListErrorViewModel {
    let error: NorrisFactsErrorType
    let isRetryEnabled: Bool
}
