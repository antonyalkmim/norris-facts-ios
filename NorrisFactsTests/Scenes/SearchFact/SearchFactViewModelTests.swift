//
//  SearchFactViewmodelTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 12/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest
import RealmSwift

@testable import NorrisFacts

class SearchFactViewModelTests: XCTestCase {
    
    var viewModel: SearchFactViewModelType!
    var factsServiceMocked: NorrisFactsServiceMocked!
    
    var disposeBag: DisposeBag!
    
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {

        disposeBag = DisposeBag()
        testScheduler = TestScheduler(initialClock: 0)
        
        factsServiceMocked = NorrisFactsServiceMocked()
        viewModel = SearchFactViewModel(factsService: factsServiceMocked)
    }
    
    override func tearDown() {
        testScheduler = nil
        disposeBag = nil
        viewModel = nil
    }
    
    func test_searchAction_whenWriteTermOnSearchField_shoulSelectTerm() {
        
        let selectSearchTermObserver = testScheduler.createObserver(String.self)
        
        viewModel.outputs.didSelectSearchTerm
            .subscribe(selectSearchTermObserver)
            .disposed(by: disposeBag)
        
        viewModel.inputs.searchTerm.onNext("dev")
        viewModel.inputs.searchAction.onNext(())
        
        testScheduler.start()
        
        let selectedSearchTerm = selectSearchTermObserver.events
            .compactMap { $0.value.element }
            .first
        XCTAssertEqual(selectedSearchTerm, "dev")
    }
    
    func test_cancelSearch_shoudCallForCancelSearch() {
        
        let cancelObserver = testScheduler.createObserver(Void.self)
        
        viewModel.outputs.didCancelSearch
            .subscribe(cancelObserver)
            .disposed(by: disposeBag)
        
        viewModel.inputs.cancelSearch.onNext(())
        
        testScheduler.start()
        
        let cancelTapsCount = cancelObserver.events.compactMap { $0.value.element }.count
        XCTAssertEqual(cancelTapsCount, 1)
    }
    
    func test_loadSuggestions_shouldLoadUpTo8RandomSuggestions() {
        
        let suggestionsObserver = testScheduler.createObserver([SuggestionsSectionViewModel].self)
        
        let testCategories = stub("get-categories", type: [FactCategory].self) ?? []
        factsServiceMocked.getCategoriesResult = .just(testCategories)
        
        viewModel.outputs.suggestions
            .subscribe(suggestionsObserver)
            .disposed(by: disposeBag)
        
        viewModel.inputs.viewWillAppear.onNext(())
        
        testScheduler.start()
        
        let suggestionsSectionViewModel = suggestionsObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(suggestionsSectionViewModel?.count, 1)
        XCTAssertEqual(suggestionsSectionViewModel?.first?.items.count, 8)
    }
    
    func test_loasPastSearches_shouldListPastSearches() {
        
        let searchesObserver = testScheduler.createObserver([PastSearchesSectionViewModel].self)
        
        let testSearches = ["political", "sport", "food"]
        factsServiceMocked.getPastSearchTermsResult = .just(testSearches)
        
        viewModel.outputs.pastSearches
            .subscribe(searchesObserver)
            .disposed(by: disposeBag)
        
        viewModel.inputs.viewWillAppear.onNext(())
        
        testScheduler.start()
        
        let pastSearchesSectionViewModel = searchesObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(pastSearchesSectionViewModel?.count, 1)
        XCTAssertEqual(pastSearchesSectionViewModel?.first?.items.count, 3)
        XCTAssertEqual(pastSearchesSectionViewModel?.first?.items, testSearches)
    }
}
