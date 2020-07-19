//
//  FactItemViewModel.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 08/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import NorrisFacts

class FactsItemViewModelTests: XCTestCase {
    
    func test_categoryTitle_isFormatted() throws {
        let factStub = stub("fact-short-text", type: NorrisFact.self)
        let fact = try XCTUnwrap(factStub, "fact-short-text.json could not be parsed as NorrisFact")
        
        let viewModel = FactItemViewModel(fact: fact)
        XCTAssertEqual(viewModel.categoryTitle, L10n.FactsList.uncategorized.uppercased())
    }
    
    func test_factText_isFormatted() throws {
        let factStub = stub("fact-short-text", type: NorrisFact.self)
        let fact = try XCTUnwrap(factStub, "fact-short-text.json could not be parsed as NorrisFact")
        
        let viewModel = FactItemViewModel(fact: fact)
        XCTAssertEqual(viewModel.factText, fact.text)
    }
    
    func test_factItemViewModel_isEquatable() throws {
        let factStub = stub("fact-short-text", type: NorrisFact.self)
        let fact = try XCTUnwrap(factStub, "fact-short-text.json could not be parsed as NorrisFact")
        
        let viewModelToTest = FactItemViewModel(fact: fact)
        let viewModel = FactItemViewModel(fact: fact)
        XCTAssertEqual(viewModelToTest, viewModel)
    }
    
    func test_factItemViewModel_isIdentifiable() throws {
        let factStub = stub("fact-short-text", type: NorrisFact.self)
        let fact = try XCTUnwrap(factStub, "fact-short-text.json could not be parsed as NorrisFact")
        
        let viewModelToTest = FactItemViewModel(fact: fact)
        XCTAssertEqual(viewModelToTest.identity, fact.id)
    }
}
