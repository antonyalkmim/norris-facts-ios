//
//  FactCategoryTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
@testable import NorrisFacts

class FactCategoryTests: XCTestCase {

    func test_parseFactCategoryList() throws {
        
        let jsonData = try XCTUnwrap(stub("get-categories"))
        let categories = try JSONDecoder().decode([FactCategory].self, from: jsonData)
        
        XCTAssertEqual(categories.count, 16)
        XCTAssertEqual(categories.first?.title, "animal")
        XCTAssertEqual(categories.last?.title, "travel")
    }

}
