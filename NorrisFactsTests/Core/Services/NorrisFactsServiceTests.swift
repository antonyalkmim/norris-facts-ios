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
        
        let categories = storageMock.getCategories()
            .observeOn(MainScheduler.instance)
            
        let initialCategories = try categories.toBlocking().first() ?? []
        XCTAssertTrue(initialCategories.isEmpty)
        
        let jsonData = "[\"develop\", \"political\", \"tecnology\"]".data(using: .utf8)!
        apiMock.responseResult = .success(jsonData)
        
        service.syncFactsCategories()
            .subscribe()
            .disposed(by: disposeBag)
        
        let savedCategories = try categories.toBlocking().first() ?? []
        XCTAssertEqual(savedCategories.count, 3)
    }
    
    func testGetCategories() throws {
        
        let categories = storageMock.getCategories()

        let initialCategories = try categories.toBlocking().first() ?? []
        XCTAssertTrue(initialCategories.isEmpty)
        
        let testCategories = stub("get-categories", type: [FactCategory].self) ?? []
        storageMock.saveCategories(testCategories)
        
        let savedCategories = try categories.toBlocking().first() ?? []
        XCTAssertEqual(savedCategories.count, testCategories.count)
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
        
        let facts = storageMock.getFacts(searchTerm: searchTerm)
            .observeOn(MainScheduler.instance)
        
        // assert that facts were saved
        let initialFacts = try facts.toBlocking().first() ?? []
        XCTAssertTrue(initialFacts.isEmpty)
        
        service.searchFacts(searchTerm: searchTerm)
            .subscribe()
            .disposed(by: disposeBag)
        
        // assert that facts were saved
        let factsSaved = try facts.toBlocking().first() ?? []
        XCTAssertEqual(factsSaved.count, 4)
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

//final class NorrisFactsStorageMock: NorrisFactsStorageType {
//
//    var categories = [FactCategory]()
//    var facts = [NorrisFact]()
//    var searches: [String: [NorrisFact]] = ["": []]
//
//    func getCategories() -> Observable<[FactCategory]> {
//        .just(categories)
//    }
//
//    func saveCategories(_ categories: [FactCategory]) {
//        self.categories.append(contentsOf: categories)
//    }
//
//    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
//        .just(facts)
//    }
//
//    func saveFacts(_ facts: [NorrisFact]) {
//        self.facts.append(contentsOf: facts)
//    }
//
//    func saveSearch(term: String, facts: [NorrisFact]) {
//        self.searches[term] = facts
//    }
//}
