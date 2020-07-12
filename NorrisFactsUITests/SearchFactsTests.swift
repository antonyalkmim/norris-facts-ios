//
//  SearchFactsTests.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 12/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest

class SearchFactsTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
    }
    
    func testSearchFactsFillingSearchBar() throws {
        app.launchArguments = ["--ui-testing", "--reset-env", "--mock-database"]
        app.launch()
        
        // 1 - tap search button
        let searchBarButtonItem = app.navigationBars.buttons["search_bar_button_item"]
        searchBarButtonItem.tap()
        
        // 2 - fill search bar
        let searchBarField = app.searchFields.element
        searchBarField.tap()
        searchBarField.typeText("political")
        
        // 3 - tap Search button on keyboard
        app.keyboards.buttons["Search"].tap()
        
        // 4 - assert results
        
        // facts filtered by search term
        XCTAssertEqual(app.tables.cells.count, 4)
        
        // current search label
        let currentSearchTermView = app.otherElements["current_search_view"]
        XCTAssertTrue(currentSearchTermView.exists)
        let currentSearchLabel = app.staticTexts["current_search_label"]
        XCTAssertTrue(currentSearchLabel.exists)
        XCTAssertEqual(currentSearchLabel.label, "Political")
        
        // 5 - clear search
        let clearSearchButton = app.buttons["clear_search_button"]
        XCTAssertTrue(clearSearchButton.exists)
        clearSearchButton.tap()
        
        // facts without search term
        XCTAssertEqual(app.tables.cells.count, 10)
    }

}
