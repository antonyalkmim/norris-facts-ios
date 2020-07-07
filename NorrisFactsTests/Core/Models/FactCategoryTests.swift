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

    func testParseFactCategoryList() throws {
        let jsonData = "[\"develop\", \"political\", \"tecnology\"]".data(using: .utf8)!
        
        let categories = try JSONDecoder().decode([FactCategory].self, from: jsonData)
        
        XCTAssertEqual(categories.first?.title, "develop")
        XCTAssertEqual(categories.last?.title, "tecnology")
    }

}
