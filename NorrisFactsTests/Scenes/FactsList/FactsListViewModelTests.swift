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
import RealmSwift

@testable import NorrisFacts

class FactsListViewModelTests: XCTestCase {
    
    var viewModel: FactsListViewModelType!
    var factsServiceMocked: NorrisFactsServiceMocked!
    var apiMock: HttpServiceMock!
    var storageMock: NorrisFactsStorageType!
    var testRealm: Realm!
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {

        disposeBag = DisposeBag()
        
        testRealm = try Realm(configuration: .init(inMemoryIdentifier: self.name))
        
        apiMock = HttpServiceMock()
        storageMock = NorrisFactsStorage(realm: testRealm)
        
        factsServiceMocked = NorrisFactsServiceMocked()
        viewModel = FactsListViewModel(factsService: factsServiceMocked)
    }
    
    override func tearDown() {
        disposeBag = nil
        apiMock = nil
        storageMock = nil
        factsServiceMocked = nil
        viewModel = nil
        
        try? testRealm.write {
            testRealm.deleteAll()
        }
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
        XCTAssertEqual(errorViewModel?.errorMessage, L10n.Errors.noInternetConnection)
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

        let errorViewModels = errorObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(errorViewModels.count, 2)
        
        let lastErrorViewModel = errorViewModels.last
        
        let retryError = lastErrorViewModel?.factListError
        XCTAssertEqual(retryError?.error.code, NetworkError.noInternetConnection.code)
        
        switch retryError {
        case .syncCategories:
            XCTAssert(true)
        default:
            XCTFail("Error should be FactsListViewModel.FactListError.syncCategories")
        }

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
        factsServiceMocked.getFactsResult[""] = .just(factsToTest)
        
        let scheduler = TestScheduler(initialClock: 0)
        let itemsObserver = scheduler.createObserver([FactsSectionViewModel].self)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        viewModel.inputs.viewDidAppear.onNext(())
        
        scheduler.start()
        
        let sectionViewModels = itemsObserver.events.compactMap { $0.value.element }.first
        let firstSection = sectionViewModels?.first
        XCTAssertEqual(firstSection?.items.count, 10)
    }
    
    func testChangeSearchTerm() {

        let scheduler = TestScheduler(initialClock: 0)
        let itemsObserver = scheduler.createObserver([FactsSectionViewModel].self)
        
        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        
        let sportSearchResult = factsToTest
        let politicalSearchResult = Array(factsToTest.prefix(1))
        factsServiceMocked.getFactsResult["sport"] = .just(sportSearchResult)
        factsServiceMocked.getFactsResult["political"] = .just(politicalSearchResult)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        scheduler.start()
        
        // empty search
        viewModel.inputs.viewDidAppear.onNext(())
        let localItemsSearched = itemsObserver.events
            .compactMap { $0.value.element }.last?.first
        XCTAssertEqual(localItemsSearched?.items.count, 0)
        
        // sport search
        viewModel.inputs.setCurrentSearchTerm.onNext("sport")
        let sportItemsSearched = itemsObserver.events
            .compactMap { $0.value.element }.last?.first
        XCTAssertEqual(sportItemsSearched?.items.count, 13)
        
        // political search
        viewModel.inputs.setCurrentSearchTerm.onNext("political")
        let politicalItemsSearched = itemsObserver.events
            .compactMap { $0.value.element }.last?.first
        XCTAssertEqual(politicalItemsSearched?.items.count, 1)
        
        let events = itemsObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(events.count, 3)
    }
    
    func testChangeSearchTerm_ShouldFilterItems() {

        let service = NorrisFactsService(api: apiMock, storage: storageMock)
        viewModel = FactsListViewModel(factsService: service)
        
        let longTextFact = stub("fact-long-text", type: NorrisFact.self)
        storageMock.saveSearch(term: "sport", facts: [longTextFact].compactMap { $0 })
        
        let politicalFacts = stub("facts", type: [NorrisFact].self) ?? []
        storageMock.saveSearch(term: "political", facts: politicalFacts)
        
        let scheduler = TestScheduler(initialClock: 0)
        let itemsObserver = scheduler.createObserver([FactsSectionViewModel].self)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        scheduler.start()
        
        // empty search
        viewModel.inputs.viewDidAppear.onNext(())
        let localItemsSearched = itemsObserver.events
            .compactMap { $0.value.element }.last?.first
        XCTAssertEqual(localItemsSearched?.items.count, 10)
        
        // sport search
        viewModel.inputs.setCurrentSearchTerm.onNext("sport")
        let sportItemsSearched = itemsObserver.events
            .compactMap { $0.value.element }.last?.first
        XCTAssertEqual(sportItemsSearched?.items.count, 1)
        
        // political search
        viewModel.inputs.setCurrentSearchTerm.onNext("political")
        let politicalItemsSearched = itemsObserver.events
            .compactMap { $0.value.element }.last?.first
        XCTAssertEqual(politicalItemsSearched?.items.count, 13)
        
        let events = itemsObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(events.count, 3) // [local10RandomFacts, sportFacts, politicalFacts]
    }
    
    func testShowSearchForm() {
        let scheduler = TestScheduler(initialClock: 0)
        let itemsObserver = scheduler.createObserver(Void.self)
        
        viewModel.outputs.showSearchFactForm
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        viewModel.inputs.searchButtonAction.onNext(())
        viewModel.inputs.searchButtonAction.onNext(())
        
        let events = itemsObserver.events.filter { $0.value.element != nil }
        XCTAssertEqual(events.count, 2)
    }
    
}

class NorrisFactsServiceMocked: NorrisFactsServiceType {
    
    var syncFactsCategoriesResult: Observable<Void> = .just(())
    var getFactsResult: [String: Observable<[NorrisFact]>] = ["": .just([])]
    var searchFactsResult: Observable<[NorrisFact]> = .just([])
    var getCategoriesResult: Observable<[FactCategory]> = .just([])
    
    func syncFactsCategories() -> Observable<Void> {
        syncFactsCategoriesResult
    }
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        getFactsResult[searchTerm] ?? .just([])
    }
    
    func searchFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        searchFactsResult
    }
    
    func getFactCategories() -> Observable<[FactCategory]> {
        getCategoriesResult
    }
}
