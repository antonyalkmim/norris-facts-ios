//
//  FactsListViewModel.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

typealias FactsSectionViewModel = AnimatableSectionModel<String, FactItemViewModel>

protocol FactsListViewModelInput {
    var viewDidAppear: AnyObserver<Void> { get }
    var syncCategories: AnyObserver<Void> { get }
    var retryErrorAction: AnyObserver<Void> { get }
    var searchButtonAction: AnyObserver<Void> { get }
    var setCurrentSearchTerm: AnyObserver<String> { get }
}

protocol FactsListViewModelOutput {
    var isLoading: ActivityIndicator { get }
    var errorViewModel: Observable<FactListErrorViewModel> { get }
    var factsViewModels: Observable<[FactsSectionViewModel]> { get }
    var showSearchFactForm: Observable<Void> { get }
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
    var disposeBag = DisposeBag()
    
    // MARK: - RX Inputs
    
    var viewDidAppear: AnyObserver<Void>
    var syncCategories: AnyObserver<Void>
    var retryErrorAction: AnyObserver<Void>
    var searchButtonAction: AnyObserver<Void>
    var setCurrentSearchTerm: AnyObserver<String>
    
    // MARK: - RX Outputs
    
    var isLoading: ActivityIndicator
    var errorViewModel: Observable<FactListErrorViewModel>
    var factsViewModels: Observable<[FactsSectionViewModel]>
    var showSearchFactForm: Observable<Void>
    
    // MARK: - RX privates
    
    init(factsService: NorrisFactsServiceType = NorrisFactsService()) {
        self.factsService = factsService
            
        // viewDidAppear
        let viewDidAppearSubject = PublishSubject<Void>()
        self.viewDidAppear = viewDidAppearSubject.asObserver()
        
        // isLoading
        let _isLoading = ActivityIndicator()
        self.isLoading = _isLoading
        
        // retry error button
        let retryErrorActionSubject = PublishSubject<Void>()
        self.retryErrorAction = retryErrorActionSubject.asObserver()
        
        // Sync Categories
        let syncCategoriesSubject = PublishSubject<Void>()
        self.syncCategories = syncCategoriesSubject.asObserver()
        
        // current search term
        let currentSearchTerm = BehaviorSubject<String>(value: "")
        self.setCurrentSearchTerm = currentSearchTerm.asObserver()
        
        let currentErrorSubject = BehaviorSubject<FactListError?>(value: nil)
        
        // sync categories
        
        let retrySyncCategories = retryErrorActionSubject
            .withLatestFrom(currentErrorSubject)
            .compactMap { $0 }
            .filter { factListError -> Bool in
                if case FactListError.syncCategories = factListError {
                    return true
                }
                return false
            }
            .mapToVoid()
        
        let syncFactsCategoriesError = Observable.merge(viewDidAppearSubject, retrySyncCategories)
            .asObservable()
            .mapToVoid()
            .flatMapLatest {
                factsService.syncFactsCategories()
                    .trackActivity(_isLoading)
                    .asObservable()
                    .materialize()
            }
            .errors()
            .map { FactListError.syncCategories($0) }
        
        // Load facts
        
        let load10RandomFacts = Observable
            .combineLatest(viewDidAppearSubject, currentSearchTerm) { _, term in term }
            .filter { $0.isEmpty }
            .flatMapLatest { _ in
                factsService.getFacts(searchTerm: "")
                    .trackActivity(_isLoading)
                    .map { Array($0.shuffled().prefix(10)) }
            }
        
        let searchFacts = Observable
            .combineLatest(viewDidAppearSubject, currentSearchTerm) { _, term in term  }
            .skip(1)
            .map { $0 }
            .filter { !$0.isEmpty }
            .flatMapLatest {
                factsService.getFacts(searchTerm: $0)
                    .trackActivity(_isLoading)
            }
            
        let loadFacts = Observable
            .merge(load10RandomFacts, searchFacts)
            .materialize()
            .share()
        
        let loadFactsError = loadFacts
            .errors()
            .map { FactListError.loadFacts($0) }
        
        self.factsViewModels = loadFacts
            .elements()
            .map { $0.map(FactItemViewModel.init) }
            .map { [FactsSectionViewModel(model: "", items: $0)] }
        
        // General errors
        
        self.errorViewModel = Observable.merge(syncFactsCategoriesError, loadFactsError)
            .do(onNext: currentErrorSubject.onNext)
            .map(FactListErrorViewModel.init)
        
        // show search facts
        let searchButtonActionSubject = PublishSubject<Void>()
        self.searchButtonAction = searchButtonActionSubject.asObserver()
        self.showSearchFactForm = searchButtonActionSubject.asObservable()
    }
    
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
}
