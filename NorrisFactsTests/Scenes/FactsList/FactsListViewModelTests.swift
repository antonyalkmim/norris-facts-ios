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
        
        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))
        viewModel.inputs.viewDidAppear.onNext(())
        
        scheduler.start()
        
        // error message
        let errorViewModel = errorObserver.events.compactMap { $0.value.element }.first
        
        switch errorViewModel?.factListError {
        case .syncCategories:
            XCTAssert(true)
        default:
            XCTFail("Error should be FactsListViewModel.FactListError.syncCategories")
        }
        
        XCTAssertEqual(errorViewModel?.factListError.error.code, NetworkError.noInternetConnection.code)
    }
    
    func testSyncCategoriesErrorRetry() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let errorObserver = scheduler.createObserver(FactListErrorViewModel.self)
        
        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))
        
        viewModel.inputs.viewDidAppear.onNext(())
        viewModel.inputs.retryErrorAction.onNext(())
        
        scheduler.start()
        
        // error message
        let errorViewModels = errorObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(errorViewModels.count, 2)
        
        let lastErrorViewModel = errorViewModels.last
        switch lastErrorViewModel?.factListError {
        case .syncCategories:
            XCTAssert(true)
        default:
            XCTFail("Error should be FactsListViewModel.FactListError.syncCategories")
        }

        XCTAssertEqual(lastErrorViewModel?.factListError.error.code, NetworkError.noInternetConnection.code)
        
    }
    
    func testSyncCategoriesSuccess() {
        
        let scheduler = TestScheduler(initialClock: 0)
        let errorObserver = scheduler.createObserver(FactListErrorViewModel.self)
        
        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        factsServiceMocked.syncFactsCategoriesResult = .just(())
        viewModel.inputs.viewDidAppear.onNext(())
        
        scheduler.start()
        
        // error message
        let error = errorObserver.events.compactMap { $0.value.element }.first
        XCTAssertNil(error)
    }
    
    func testLoad10RandomFacts() {

        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        factsServiceMocked.getFactsResult = .just(factsToTest)
        
        let scheduler = TestScheduler(initialClock: 0)
        let itemsObserver = scheduler.createObserver([FactItemViewModel].self)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        viewModel.inputs.viewDidAppear.onNext(())
        
        scheduler.start()
        
        let itemsViewModels = itemsObserver.events.compactMap { $0.value.element }.first
        
        XCTAssertEqual(itemsViewModels?.count, 10)
    }
    
}

class NorrisFactsServiceMocked: NorrisFactsServiceType {
    
    var syncFactsCategoriesResult: Single<Void> = .just(())
    var getFactsResult: Observable<[NorrisFact]> = .just([])
    
    func syncFactsCategories() -> Single<Void> {
        syncFactsCategoriesResult
    }
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        getFactsResult
    }
}
