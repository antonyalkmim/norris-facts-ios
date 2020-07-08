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
        
        var currentCategories = try storageMock.getCategories().toBlocking().first() ?? []
        XCTAssertTrue(currentCategories.isEmpty)
        
        let jsonData = "[\"develop\", \"political\", \"tecnology\"]".data(using: .utf8)!
        apiMock.responseResult = .success(jsonData)
        
        service.syncFactsCategories()
            .subscribe()
            .disposed(by: disposeBag)
        
        currentCategories = try storageMock.getCategories().toBlocking().first() ?? []
        XCTAssertEqual(currentCategories.count, 3)
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
    
    func testGetFactsFilterBySearchTerm() throws {
        
        let scheduler = TestScheduler(initialClock: 0)
        let factsObserver = scheduler.createObserver([NorrisFact].self)
        
        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
        
        storageMock.saveFacts(factsToTest)
        
        service.getFacts(searchTerm: "political")
            .subscribe(factsObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let facts = factsObserver.events.compactMap { $0.value.element }.first
        XCTAssertEqual(facts?.count, 2)
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
