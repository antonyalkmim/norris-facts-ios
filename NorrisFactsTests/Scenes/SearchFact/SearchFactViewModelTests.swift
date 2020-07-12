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
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {

        disposeBag = DisposeBag()
        
        viewModel = SearchFactViewModel()
    }
    
    override func tearDown() {
        disposeBag = nil
        viewModel = nil
    }
    
    func testSelectSearchTermBySearchBar() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let selectSearchTermObserver = scheduler.createObserver(String.self)
        
        viewModel.outputs.didSelectSearchTerm
            .subscribe(selectSearchTermObserver)
            .disposed(by: disposeBag)
        
        viewModel.inputs.searchTerm.onNext("dev")
        viewModel.inputs.searchAction.onNext(())
        
        scheduler.start()
        
        let selectedSearchTerm = selectSearchTermObserver.events
            .compactMap { $0.value.element }
            .first
        XCTAssertEqual(selectedSearchTerm, "dev")
    }
    
    func testCancelSearch() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let cancelObserver = scheduler.createObserver(Void.self)
        
        viewModel.outputs.didCancelSearch
            .subscribe(cancelObserver)
            .disposed(by: disposeBag)
        
        viewModel.inputs.cancelSearch.onNext(())
        
        scheduler.start()
        
        let cancelTapsCount = cancelObserver.events.compactMap { $0.value.element }.count
        XCTAssertEqual(cancelTapsCount, 1)
    }
    
}
