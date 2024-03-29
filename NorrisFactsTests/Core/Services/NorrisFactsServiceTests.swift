//
//  NorrisFactsServiceTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest
import RealmSwift

@testable import NorrisFacts

class NorrisFactsServiceTests: XCTestCase {

    var service: NorrisFactsServiceType!
    var apiMock: HttpServiceMock!
    var storageMock: NorrisFactsStorageType!
    var testRealm: Realm!
    
    var disposeBag: DisposeBag!
    
    var testScheduler: TestScheduler!
    
    override func setUpWithError() throws {
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        
        apiMock = HttpServiceMock()
        
        testRealm = try Realm(configuration: .init(inMemoryIdentifier: self.name))
        storageMock = NorrisFactsStorage(realm: testRealm)
        
        service = NorrisFactsService(api: apiMock,
                                     storage: storageMock,
                                     scheduler: testScheduler)
    }
    
    override func tearDown() {
        disposeBag = nil
        apiMock = nil
        storageMock = nil
        service = nil
        
        try? testRealm.write {
            testRealm.deleteAll()
        }
    }
    
    func test_syncCategories_shouldSaveCategoriesOnDatabase() throws {
        
        apiMock.mockRequest(statusCode: 200, stub("get-categories"))
        
        let categoriesObserver = testScheduler.createObserver([FactCategory].self)
        
        testScheduler
            .createHotObservable([
                .next(0, ()),
                .next(100, ())
            ])
            .flatMapLatest(service.getFactCategories)
            .subscribe(categoriesObserver)
            .disposed(by: disposeBag)
        
        service.syncFactsCategories()
            .subscribe()
            .disposed(by: disposeBag)
        
        testScheduler.start()
        
        let events = categoriesObserver.events.compactMap { $0.value.element }

        // assert database its empty at the first query
        XCTAssertEqual(events.first?.count, 0)

        // assert database its not empty after call syncCategories
        XCTAssertEqual(events.last?.count, 16)
    }
    
    func test_getCategories_shouldReturnCategoriesOnDatabase() throws {
        
        let categories = storageMock.getCategories()

        // test when database is empty
        let initialCategories = try categories.toBlocking().first() ?? []
        XCTAssertTrue(initialCategories.isEmpty)
        
        let testCategories = stub("get-categories", type: [FactCategory].self) ?? []
        storageMock.saveCategories(testCategories)
        
        // test when database is not empty
        let savedCategories = try categories.toBlocking().first() ?? []
        XCTAssertEqual(savedCategories.count, testCategories.count)
    }
    
    func test_getFacts_whenSearchTermEmpty_shouldReturnLocalFacts() throws {
        
        let factsObserver = testScheduler.createObserver([NorrisFact].self)
        
        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        storageMock.saveFacts(factsToTest)
        
        service.getFacts(searchTerm: "")
            .subscribe(factsObserver)
            .disposed(by: disposeBag)
        
        testScheduler.start()
        
        let facts = factsObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(facts?.count, 13)
    }
    
    func test_searchFacts_withSearchTerm_shouldSaveNewFactsOnDatabase() throws {

        apiMock.mockRequest(statusCode: 200, stub("search-facts-response"))
        
        let factsObserver = testScheduler.createObserver([NorrisFact].self)

        let searchTerm = "sport"
        
        testScheduler
            .createHotObservable([
                .next(0, searchTerm),
                .next(100, searchTerm)
            ])
            .flatMapLatest(service.getFacts)
            .subscribe(factsObserver)
            .disposed(by: disposeBag)
        
        service.searchFacts(searchTerm: searchTerm)
            .subscribe()
            .disposed(by: disposeBag)
        
        testScheduler.start()

        let events = factsObserver.events.compactMap { $0.value.element }

        // assert database its empty at the first query
        XCTAssertEqual(events.first?.count, 0)

        // assert database its not empty after call search
        XCTAssertEqual(events.last?.count, 4)
    }
    
    func test_searchFacts_withApiStatusCodeError_returnsNetworkError() throws {

        let factsObserver = testScheduler.createObserver([NorrisFact].self)
        apiMock.mockRequest(statusCode: 500, nil)
        
        service.searchFacts(searchTerm: "sport")
            .subscribe(factsObserver)
            .disposed(by: disposeBag)
        
        testScheduler.start()

        let error = try XCTUnwrap(factsObserver.events.compactMap { $0.value.error as? NorrisFactsError }.first)
        guard case let NorrisFactsError.network(networkError) = error else {
            XCTFail("Error should be NetworkError")
            return
        }
        
        XCTAssertEqual(networkError, .statusCodeError(500))
    }
    
    func test_gestFacts_withSearchTerm_shouldFilterFacts() throws {
        
        let scheduler = TestScheduler(initialClock: 0)
        let factsObserver = scheduler.createObserver([NorrisFact].self)
        let searchTerm = "political"
        
        // save data for test searchTerm (political)
        let fakeFacts = stub("facts", type: [NorrisFact].self) ?? []
        storageMock.saveSearch(term: searchTerm, facts: fakeFacts)
        
        // save data that should not be listed
        let longFactStub = stub("fact-long-text", type: NorrisFact.self)
        let longFact = try XCTUnwrap(longFactStub, "longFactStub should not be nil")
        
        storageMock.saveSearch(term: "sport", facts: [longFact])
        
        service.getFacts(searchTerm: searchTerm)
            .subscribe(factsObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let allFacts = try storageMock.getFacts(searchTerm: "")
            .toBlocking(timeout: executionTimeAllowance)
            .first() ?? []
        XCTAssertEqual(allFacts.count, 14)
        
        let facts = factsObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(facts?.count, 13)
    }
    
    func test_loadPastSearchTerms_returnsDistinctTermsSortedByDate() throws {
        
        let fakeFacts = stub("facts", type: [NorrisFact].self) ?? []
        let longFactStub = stub("fact-long-text", type: NorrisFact.self)
        let longFact = try XCTUnwrap(longFactStub, "longFactStub should not be nil")
        
        storageMock.saveSearch(term: "political", facts: fakeFacts)
        storageMock.saveSearch(term: "sport", facts: [longFact])
        storageMock.saveSearch(term: "food", facts: [longFact])
        storageMock.saveSearch(term: "sport", facts: [longFact])
        
        let searches = try storageMock.getPastSearchTerms().toBlocking().first() ?? []
        XCTAssertEqual(searches, ["sport", "food", "political"])
    }

}
