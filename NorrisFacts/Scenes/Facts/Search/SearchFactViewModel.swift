//
//  SearchFactViewModel.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 11/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

typealias SuggestionsSectionViewModel = SectionModel<String, String>
typealias PastSearchesSectionViewModel = SectionModel<String, String>

protocol SearchFactViewModelInput {
    /// Call when view did appear to start loading facts and sync categories
    var viewDidAppear: AnyObserver<Void> { get }
    
    /// Search term filled in searchBar
    var searchTerm: AnyObserver<String> { get }
    
    /// Call when should call API to search
    var searchAction: AnyObserver<Void> { get }
    
    /// Call when taps cancel button
    var cancelSearch: AnyObserver<Void> { get }
}

protocol SearchFactViewModelOutput {
    /// Emmit event to coordinator with searchTerm that should be request on API
    var didSelectSearchTerm: Observable<String> { get }
    
    // Emmit event to cancel search and close search screen
    var didCancelSearch: Observable<Void> { get }
    
    // Emmit suggetions to search facts
    var suggestions: Observable<[SuggestionsSectionViewModel]> { get }
    
    // Emmit past searches
    var pastSearches: Observable<[PastSearchesSectionViewModel]> { get }
}

protocol SearchFactViewModelType {
    var inputs: SearchFactViewModelInput { get }
    var outputs: SearchFactViewModelOutput { get }
}

final class SearchFactViewModel: SearchFactViewModelType, SearchFactViewModelInput, SearchFactViewModelOutput {
    
    var inputs: SearchFactViewModelInput { self }
    var outputs: SearchFactViewModelOutput { self }
    
    // MARK: - Dependencies
    
    let factsService: NorrisFactsServiceType
    
    // MARK: - RX Inputs
    
    var viewDidAppear: AnyObserver<Void>
    var searchTerm: AnyObserver<String>
    var searchAction: AnyObserver<Void>
    var cancelSearch: AnyObserver<Void>
    
    // MARK: - RX Outputs
    
    var didSelectSearchTerm: Observable<String>
    var didCancelSearch: Observable<Void>
    var suggestions: Observable<[SuggestionsSectionViewModel]>
    var pastSearches: Observable<[PastSearchesSectionViewModel]>
    
    let suggestionsMock = ["Political", "Develop", "Github", "Sports", "Explicit", "Technology", "Food", "Love"]
    let pastSearchesMock = ["Political", "Develop", "Github", "Sports", "Explicit", "Technology", "Food", "Love", "Political", "Develop", "Github", "Sports", "Explicit", "Technology", "Food", "Love"]
    
    init(factsService: NorrisFactsServiceType = NorrisFactsService()) {
        
        self.factsService = factsService
        
        // viewDidAppear
        let viewDidAppearSubject = PublishSubject<Void>()
        self.viewDidAppear = viewDidAppearSubject.asObserver()
        
        // searchTerm
        let searchTermSubject = BehaviorSubject<String>(value: "")
        self.searchTerm = searchTermSubject.asObserver()
        
        // searchAction
        let searchActionSubject = PublishSubject<Void>()
        self.searchAction = searchActionSubject.asObserver()
        
        // cancel search
        let cancelSearchSubject = PublishSubject<Void>()
        self.cancelSearch = cancelSearchSubject.asObserver()
        self.didCancelSearch = cancelSearchSubject.asObservable()
        
        // select search term
        self.didSelectSearchTerm = searchActionSubject
            .withLatestFrom(searchTermSubject)
            .filter { !$0.isEmpty }
        
        self.suggestions = Observable.just(suggestionsMock)
            .map { [SuggestionsSectionViewModel(model: "", items: $0)] }
        
        self.pastSearches = Observable.just(pastSearchesMock)
            .map { [PastSearchesSectionViewModel(model: "", items: $0)] }
    }
}
