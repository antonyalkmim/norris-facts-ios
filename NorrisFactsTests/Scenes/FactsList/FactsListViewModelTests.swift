//
//  FactsListViewModelTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import NorrisFacts

class FactsListViewModelTests: XCTestCase {
    
    var viewModel: FactsListViewModelType!
    var factsServiceMocked: NorrisFactsServiceMocked!
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
        
        factsServiceMocked = NorrisFactsServiceMocked()
        viewModel = FactsListViewModel(factsService: factsServiceMocked)
    }
    
    override func tearDown() {
        disposeBag = nil
        factsServiceMocked = nil
        viewModel = nil
    }
    
    func testSyncCategoriesError() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let errorObserver = scheduler.createObserver(FactListErrorViewModel.self)
        
        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        factsServiceMocked.error = .network(.noInternetConnection)
        viewModel.inputs.syncCategories.onNext(())
        
        scheduler.start()
        
        // error message
        let errorViewModel = errorObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(errorViewModel?.error.code, NetworkError.noInternetConnection.code)
    }
    
    func testSyncCategoriesSuccess() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let errorObserver = scheduler.createObserver(FactListErrorViewModel.self)
        
        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        factsServiceMocked.error = nil
        viewModel.inputs.syncCategories.onNext(())
        
        scheduler.start()
        
        // error message
        let error = errorObserver.events.compactMap { $0.value.element }.first
        XCTAssertNil(error)
    }
    
}

class NorrisFactsServiceMocked: NorrisFactsServiceType {
    
    var error: NorrisFactsError?
    
    func syncFactsCategories() -> Single<Void> {
        error != nil ? .error(error!) : .just(())
    }
}
