//
//  NorrisFactsUITests.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest

class FactsListTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
    }

    func testShowEmptyViewWhenFirstAccess() throws {
        app.launchArguments = ["--ui-testing", "--reset-env"]
        app.launch()
        
        let searchBarButtonItem = app.navigationBars.buttons["search_bar_button_item"]
        XCTAssertTrue(searchBarButtonItem.exists)
        
        let emptyView = app.otherElements["empty_view"]
        XCTAssertTrue(emptyView.exists)
        
        let emptyViewLabel = app.staticTexts["empty_view_label"]
        XCTAssertTrue(emptyViewLabel.exists)
        
        let emptyViewButton = app.buttons["empty_view_button"]
        XCTAssertTrue(emptyViewButton.exists)
        XCTAssertTrue(emptyViewButton.isEnabled)
    }
    
    func testLoad10RandomFacts() throws {
        app.launchArguments = ["--ui-testing", "--reset-env", "--mock-database"]
        app.launch()
        
        XCTAssertEqual(app.tables.cells.count, 10)
    }

}
