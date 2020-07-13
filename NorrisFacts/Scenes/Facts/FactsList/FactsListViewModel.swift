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
    
    /// Call when view did appear to start loading facts and sync categories
    var viewDidAppear: AnyObserver<Void> { get }
    
    /// Call to retry the last errored operation. Ex: syncCategories
    var retryErrorAction: AnyObserver<Void> { get }
    
    /// Call to show the search form screen
    var searchButtonAction: AnyObserver<Void> { get }
    
    /// Call to update the current search term
    var setCurrentSearchTerm: AnyObserver<String> { get }
}

protocol FactsListViewModelOutput {
    
    /// Emmits an boolean indicating if is loading something from API
    var isLoading: ActivityIndicator { get }
    
    /// Emmits an errorViewModel to be shown
    var errorViewModel: Observable<FactListErrorViewModel> { get }
    
    /// Emmits an array of section viewmodels to bind on tableView
    var factsViewModels: Observable<[FactsSectionViewModel]> { get }
    
    /// Emmits an event to coordinator present the search form screen
    var showSearchFactForm: Observable<Void> { get }
    
    /// Emmits an event of current searchTerm to be shown
    var currentSearchTerm: Observable<String> { get }
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
    var retryErrorAction: AnyObserver<Void>
    var searchButtonAction: AnyObserver<Void>
    var setCurrentSearchTerm: AnyObserver<String>
    
    // MARK: - RX Outputs
    
    var isLoading: ActivityIndicator
    var errorViewModel: Observable<FactListErrorViewModel>
    var factsViewModels: Observable<[FactsSectionViewModel]>
    var showSearchFactForm: Observable<Void>
    var currentSearchTerm: Observable<String>
    
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
        
        // current search term
        let currentSearchTermSubject = BehaviorSubject<String>(value: "")
        self.setCurrentSearchTerm = currentSearchTermSubject.asObserver()
        self.currentSearchTerm = currentSearchTermSubject.asObservable()
        
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
        
        // attempt to sync categories when view appears of user taps the retryButton
        let syncFactsCategoriesError = Observable.merge(viewDidAppearSubject, retrySyncCategories)
            .asObservable()
            .mapToVoid()
            .flatMapLatest {
                factsService.syncFactsCategories()
                    .asObservable()
                    .materialize()
            }
            .errors()
            .map { FactListError.syncCategories($0) }
        
        // search facts filtering by currentSearchTerm
        let searchFacts = Observable
            .combineLatest(viewDidAppearSubject, currentSearchTerm) { _, term in term }
            .filter { !$0.isEmpty }
            .flatMapLatest {
                factsService.searchFacts(searchTerm: $0)
                    .trackActivity(_isLoading)
            }
        
        let searchFactsError = searchFacts
            .materialize()
            .errors()
            .map { FactListError.loadFacts($0) }
        
        self.factsViewModels = Observable
            .combineLatest(viewDidAppearSubject, currentSearchTerm) { _, term in term }
            .flatMapLatest { term -> Observable<[NorrisFact]> in
                guard !term.isEmpty else {
                    return factsService.getFacts(searchTerm: "")
                        .map { Array($0.shuffled().prefix(10)) }
                }
                return factsService.getFacts(searchTerm: term)
            }
            .materialize()
            .elements()
            .map { $0.map(FactItemViewModel.init) }
            .map { [FactsSectionViewModel(model: "", items: $0)] }
        
        // General errors

        self.errorViewModel = Observable.merge(syncFactsCategoriesError, searchFactsError)
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
