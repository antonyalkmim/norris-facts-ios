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
    var testScheduler: TestScheduler!
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        
        testScheduler = TestScheduler(initialClock: 0)
        
        testRealm = try Realm(configuration: .init(inMemoryIdentifier: self.name))
        
        apiMock = HttpServiceMock()
        storageMock = NorrisFactsStorage(realm: testRealm)
        
        factsServiceMocked = NorrisFactsServiceMocked()
        viewModel = FactsListViewModel(factsService: factsServiceMocked)
    }
    
    override func tearDown() {
        disposeBag = nil
        testScheduler = nil
        apiMock = nil
        storageMock = nil
        factsServiceMocked = nil
        viewModel = nil
        
        try? testRealm.write {
            testRealm.deleteAll()
        }
    }
    
    func test_syncCategories_withError_shouldEmmitErrorViewModel() {
        
        let errorObserver = testScheduler.createObserver(FactListErrorViewModel.self)
        
        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))
        viewModel.inputs.viewDidAppear.onNext(())
        
        testScheduler.start()
        
        // error message
        let errorViewModel = errorObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(errorViewModel?.errorMessage, L10n.Errors.noInternetConnection)
    }
    
    func test_retrySyncCategories() {

        let errorObserver = testScheduler.createObserver(FactListErrorViewModel.self)

        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)

        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))

        viewModel.inputs.viewDidAppear.onNext(())
        viewModel.inputs.retryErrorAction.onNext(())

        testScheduler.start()

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
    
    func test_syncCategories_withSuccessApiResponse_shouldNotReturnError() {
        
        let errorObserver = testScheduler.createObserver(FactListErrorViewModel.self)
        
        viewModel.outputs.errorViewModel
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        factsServiceMocked.syncFactsCategoriesResult = .just(())
        viewModel.inputs.viewDidAppear.onNext(())
        
        testScheduler.start()
        
        // error message
        let error = errorObserver.events.compactMap { $0.value.element }.first
        XCTAssertNil(error)
    }
    
    func test_factsViewModels_withEmptySearchTerm_shouldLoad10RandomFacts() {

        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        factsServiceMocked.getFactsResult[""] = .just(factsToTest)
        
        let itemsObserver = testScheduler.createObserver([FactsSectionViewModel].self)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        viewModel.inputs.viewDidAppear.onNext(())
        
        testScheduler.start()
        
        let sectionViewModels = itemsObserver.events.compactMap { $0.value.element }.first
        let firstSection = sectionViewModels?.first
        XCTAssertEqual(firstSection?.items.count, 10)
    }
    
    func test_setCurrentSearchTerm_shouldSearchFactsForTerm() {

        let itemsObserver = testScheduler.createObserver([FactsSectionViewModel].self)
        
        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        
        let sportSearchResult = factsToTest
        let politicalSearchResult = Array(factsToTest.prefix(1))
        factsServiceMocked.getFactsResult["sport"] = .just(sportSearchResult)
        factsServiceMocked.getFactsResult["political"] = .just(politicalSearchResult)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        testScheduler.start()
        
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
    
    func test_setCurrentSearchTerm_shouldFilterLocalFacts() throws {

        let service = NorrisFactsService(api: apiMock, storage: storageMock)
        viewModel = FactsListViewModel(factsService: service)
        
        let longTextFact = try XCTUnwrap(stub("fact-long-text", type: NorrisFact.self))
        storageMock.saveSearch(term: "sport", facts: [longTextFact])
        
        let politicalFacts = try XCTUnwrap(stub("facts", type: [NorrisFact].self))
        storageMock.saveSearch(term: "political", facts: politicalFacts)
        
        let itemsObserver = testScheduler.createObserver([FactsSectionViewModel].self)
        
        viewModel.outputs.factsViewModels
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)

        testScheduler.start()
        
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
    
    func test_showSearchForm() {
        let itemsObserver = testScheduler.createObserver(Void.self)
        
        viewModel.outputs.showSearchFactForm
            .subscribe(itemsObserver)
            .disposed(by: disposeBag)
        
        testScheduler.start()
        
        viewModel.inputs.searchButtonAction.onNext(())
        viewModel.inputs.searchButtonAction.onNext(())
        
        let events = itemsObserver.events.filter { $0.value.element != nil }
        XCTAssertEqual(events.count, 2)
    }
    
    func test_showShareScreen() throws {
        
        let longFactStub = stub("fact-long-text", type: NorrisFact.self)
        let longFact = try XCTUnwrap(longFactStub, "fact-long-text.json could not be parsed as NorrisFact")
        
        let shareObserver = testScheduler.createObserver(NorrisFact.self)
        
        viewModel.outputs.shareFact
            .subscribe(shareObserver)
            .disposed(by: disposeBag)
        
        testScheduler.start()
        
        let factItemViewModel = FactItemViewModel(fact: longFact)
        viewModel.inputs.shareItemAction.onNext(factItemViewModel)
        
        let shareFact = shareObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(shareFact?.id, longFact.id)
    }
    
}
