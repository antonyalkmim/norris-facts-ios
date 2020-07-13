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
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        
        apiMock = HttpServiceMock()
        
        testRealm = try Realm(configuration: .init(inMemoryIdentifier: self.name))
        storageMock = NorrisFactsStorage(realm: testRealm)
        
        service = NorrisFactsService(api: apiMock,
                                     storage: storageMock)
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
    
    func testSyncCategories() throws {
        
        var currentCategories = try storageMock.getCategories()
            .toBlocking()
            .first() ?? []
        XCTAssertTrue(currentCategories.isEmpty)
        
        let jsonData = "[\"develop\", \"political\", \"tecnology\"]".data(using: .utf8)!
        apiMock.responseResult = .success(jsonData)
        
        service.syncFactsCategories()
            .observeOn(MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
        
        currentCategories = try storageMock.getCategories()
            .toBlocking()
            .first() ?? []
        XCTAssertEqual(currentCategories.count, 3)
    }
    
    func testGetCategories() throws {
        
        var currentCategories = try storageMock.getCategories()
            .toBlocking()
            .first() ?? []
        XCTAssertTrue(currentCategories.isEmpty)
        
        let testCategories = stub("get-categories", type: [FactCategory].self) ?? []
        storageMock.saveCategories(testCategories)
        
        currentCategories = try storageMock.getCategories()
            .toBlocking()
            .first() ?? []
        XCTAssertEqual(currentCategories.count, testCategories.count)
    }
    
    func testGetFacts() throws {
        
        let scheduler = TestScheduler(initialClock: 0)
        let factsObserver = scheduler.createObserver([NorrisFact].self)
        
        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        storageMock.saveFacts(factsToTest)
        
        service.getFacts(searchTerm: "")
            .subscribe(factsObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let facts = factsObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(facts?.count, 13)
    }
    
    func testSearchFactsBySearchTerm_ShouldSaveNewFacts() throws {
        
        let searchTerm = "sport"
        
        let responseData = stub("search-facts-response") ?? Data()
        apiMock.responseResult = .success(responseData)
        
        // assert the database is empty
        var currentFacts = try storageMock.getFacts(searchTerm: searchTerm)
            .toBlocking(timeout: executionTimeAllowance)
            .first() ?? []
        XCTAssertTrue(currentFacts.isEmpty)
        
        service.searchFacts(searchTerm: searchTerm)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe()
            .disposed(by: disposeBag)
        
        // assert that facts were saved
        currentFacts = try storageMock.getFacts(searchTerm: searchTerm)
            .toBlocking(timeout: executionTimeAllowance)
            .first() ?? []
        XCTAssertFalse(currentFacts.isEmpty)
    }
    
    func testGestFactsByTerm_ShouldFilter() throws {
        
        let scheduler = TestScheduler(initialClock: 0)
        let factsObserver = scheduler.createObserver([NorrisFact].self)
        let searchTerm = "political"
        
        // save data for test searchTerm (political)
        let fakeFacts = stub("facts", type: [NorrisFact].self) ?? []
        storageMock.saveSearch(term: searchTerm, facts: fakeFacts)
        
        // save data that should not be listed
        guard let smallFact = stub("fact-long-text", type: NorrisFact.self) else {
            XCTFail("smallFact should not be nil")
            return
        }
        storageMock.saveSearch(term: "sport", facts: [smallFact])
        
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

}

final class HttpServiceMock: HttpService<NorrisFactsAPI> {
    
    var responseResult: Result<Data, NorrisFactsError>?
    
    override func request(_ endpoint: NorrisFactsAPI,
                          responseData: @escaping (Result<Data, NorrisFactsError>) -> Void) -> URLSessionDataTask? {
        responseData(responseResult ?? .failure(.unknow(nil)))
        return nil
    }
}
