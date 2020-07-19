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
        app.setLaunchArguments([.uiTest, .resetEnviroments])
        app.launch()
        
        let factsScreen = FactsListScreen()
        
        XCTAssertTrue(factsScreen.searchBarButtonItem.exists)
        XCTAssertTrue(factsScreen.emptyView.exists)
        XCTAssertTrue(factsScreen.emptyViewLabel.exists)
        XCTAssertTrue(factsScreen.emptyViewButton.exists)
        XCTAssertTrue(factsScreen.emptyViewButton.isEnabled)
    }
    
    func testLoad10RandomFacts() throws {
        app.setLaunchArguments([.uiTest, .resetEnviroments, .useMockDatabase])
        app.launch()
        
        let factsScreen = FactsListScreen()
        XCTAssertEqual(factsScreen.factsTableView.cells.count, 10)
    }
    
    func testShareFact() throws {
        app.setLaunchArguments([.uiTest, .resetEnviroments, .useMockDatabase])
        app.launch()
        
        // 1 - init in facts list screen
        let factsListScreen = FactsListScreen()
        XCTAssertTrue(factsListScreen.firstCell().shareButton.exists)
        
        // 2 - tap on share button
        factsListScreen.firstCell().shareButton.tap()
    
        // 3 - assert share screen was loaded
        let shareScreen = ShareScreen()
        XCTAssertTrue(shareScreen.activityList.waitForExistence(timeout: 1))
        
        shareScreen.closeButton.tap()
        
        waitForElementToNotExist(element: shareScreen.activityList)
    }
    
    func testShowToastForErrorsWithNotEmptyList() throws {
        app.setLaunchArguments([.uiTest, .resetEnviroments, .useMockDatabase, .useMockErrorHttpRequests])
        app.launch()
        
        let factsScreen = FactsListScreen()
        let searchScreen = SearchScreen()
        
        // 1 - attempt to search a fact
        factsScreen.searchBarButtonItem.tap()
        searchScreen.firstPastSearchCell().element.tap()
        
        // assert toastView is visible
        XCTAssertTrue(factsScreen.toastView.waitForExistence(timeout: 2))
        
        waitForElementToNotExist(element: factsScreen.toastView)
    }

}
