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
    
    /// Call when user taps item in the list
    var shareItemAction: AnyObserver<FactItemViewModel> { get }
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
    
    /// Emmits an event to coordinator present the share screen for NorrisFact
    var shareFact: Observable<NorrisFact> { get }
}

protocol FactsListViewModelType {
    var inputs: FactsListViewModelInput { get }
    var outputs: FactsListViewModelOutput { get }
}

struct FactsListViewModel: FactsListViewModelType, FactsListViewModelInput, FactsListViewModelOutput {
    
    var inputs: FactsListViewModelInput { self }
    var outputs: FactsListViewModelOutput { self }
    
    // MARK: - Dependencies
    
    let factsService: NorrisFactsServiceType
    
    // MARK: - RX Inputs
    
    var viewDidAppear: AnyObserver<Void>
    var retryErrorAction: AnyObserver<Void>
    var searchButtonAction: AnyObserver<Void>
    var setCurrentSearchTerm: AnyObserver<String>
    var shareItemAction: AnyObserver<FactItemViewModel>
    
    // MARK: - RX Outputs
    
    var isLoading: ActivityIndicator
    var errorViewModel: Observable<FactListErrorViewModel>
    var factsViewModels: Observable<[FactsSectionViewModel]>
    var showSearchFactForm: Observable<Void>
    var currentSearchTerm: Observable<String>
    var shareFact: Observable<NorrisFact>
    
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
        
        // show search facts
        let searchButtonActionSubject = PublishSubject<Void>()
        self.searchButtonAction = searchButtonActionSubject.asObserver()
        self.showSearchFactForm = searchButtonActionSubject.asObservable()
        
        // show share screen
        let shareItemSubject = PublishSubject<FactItemViewModel>()
        self.shareItemAction = shareItemSubject.asObserver()
        self.shareFact = shareItemSubject.map { $0.fact }
            .asObservable()
        
        let currentErrorSubject = BehaviorSubject<FactListError?>(value: nil)
        
        // Sync categories
        
        let retrySyncCategories = retryErrorActionSubject
            .withLatestFrom(currentErrorSubject)
            .compactMap { $0 }
            .filter { $0 == .syncCategories($0.error) }
            .mapToVoid()
        
        // attempt to sync categories when view appears or user taps the retryButton
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
        
        // Search Facts
        
        // search facts filtering by currentSearchTerm
        let searchFacts = Observable
            .combineLatest(viewDidAppearSubject, currentSearchTerm) { _, term in term }
            .filter { !$0.isEmpty }
            .flatMapLatest {
                factsService.searchFacts(searchTerm: $0)
                    .trackActivity(_isLoading)
                    .materialize()
            }
        
        let searchFactsError = searchFacts
            .errors()
            .map { FactListError.loadFacts($0) }
        
        self.factsViewModels = Observable
            .combineLatest(viewDidAppearSubject, currentSearchTerm) { _, term in term }
            .flatMapLatest { term -> Observable<[NorrisFact]> in
                
                // show 10 random facts if currentSearchTerm is empty
                guard !term.isEmpty else {
                    return factsService.getFacts(searchTerm: "")
                        .map { Array($0.shuffled().prefix(10)) }
                }
                
                // show searched facts for currentSerchTerm when its not empty
                return factsService.getFacts(searchTerm: term)
            }
            .materialize()
            .elements()
            .map { $0.map(FactItemViewModel.init) }
            .map { [FactsSectionViewModel(model: "", items: $0)] }
        
        // General errors
        // emmit errors when syncCategories or searchFact emmits an error
        self.errorViewModel = Observable.merge(syncFactsCategoriesError, searchFactsError)
            .do(onNext: currentErrorSubject.onNext)
            .map(FactListErrorViewModel.init)
    }

}
