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
        app.setLaunchArguments([
            .uiTest,
            .resetEnviroments,
            .useMockDatabase,
            .useMockHttpRequests
        ])
        app.launch()
        
        // 1 - tap search button
        let factsScreen = FactsListScreen()
        factsScreen.searchBarButtonItem.tap()
        
        // 2 - fill search bar
        let searchScreen = SearchScreen()
        searchScreen.searchBarField.tap()
        searchScreen.searchBarField.typeText("political")
        
        // 3 - tap Search button on keyboard
        app.keyboards.buttons["Search"].tap()
        
        // 4 - assert results
        
        // facts filtered by search term
        XCTAssertEqual(factsScreen.factsTableView.cells.count, 4)
        
        // current search label
        XCTAssertTrue(factsScreen.currentSearchTermView.exists)
        XCTAssertTrue(factsScreen.currentSearchLabel.exists)
        XCTAssertEqual(factsScreen.currentSearchLabel.label, "Political")
        
        // 5 - clear search
        XCTAssertTrue(factsScreen.clearSearchButton.exists)
        factsScreen.clearSearchButton.tap()
        
        // facts without search term
        XCTAssertEqual(factsScreen.factsTableView.cells.count, 10)
    }
    
    func testSearchFactsTappingInSuggestions() {
        app.setLaunchArguments([
            .uiTest,
            .resetEnviroments,
            .useMockDatabase,
            .useMockHttpRequests
        ])
        app.launch()
        
        // 1 - tap search button
        let factsScreen = FactsListScreen()
        factsScreen.searchBarButtonItem.tap()
        
        // 2 - tap suggestions
        let searchScreen = SearchScreen()
        XCTAssertTrue(searchScreen.suggestionsCollectionView.exists)
        
        let searchTerm = searchScreen.firstSuggestionCell().tagTextView.label
        searchScreen.firstSuggestionCell().element.tap()
        
        // 4 - assert results
        
        // facts filtered by search term
        XCTAssertEqual(factsScreen.factsTableView.cells.count, 4)
        
        // current search label
        XCTAssertTrue(factsScreen.currentSearchTermView.exists)
        XCTAssertTrue(factsScreen.currentSearchLabel.exists)
        XCTAssertEqual(factsScreen.currentSearchLabel.label, searchTerm.capitalized)
        
        // 5 - clear search
        XCTAssertTrue(factsScreen.clearSearchButton.exists)
        factsScreen.clearSearchButton.tap()
        
        // facts without search term
        XCTAssertEqual(factsScreen.factsTableView.cells.count, 10)
    }
    
    func testSearchTermSaveInPastSearches() {
        app.setLaunchArguments([.uiTest, .resetEnviroments, .useMockHttpRequests])
        app.launch()
        
        let factsScreen = FactsListScreen()
        let searchScreen = SearchScreen()
         
        // 1 - tap search button
        factsScreen.searchBarButtonItem.tap()
        
        // 2 - tap suggestions
        searchScreen.firstSuggestionCell().element.tap()
        
        // 4 - tap search button again
        factsScreen.searchBarButtonItem.tap()
        
        // 5 - fill search bar
        searchScreen.searchBarField.tap()
        searchScreen.searchBarField.typeText("political")
        
        app.keyboards.buttons["Search"].tap()
        
        // 6 - open search screen again
        factsScreen.searchBarButtonItem.tap()
        
        XCTAssertTrue(searchScreen.pastSearchTableView.exists)
        XCTAssertEqual(searchScreen.pastSearchTableView.cells.count, 2)
        
        XCTAssertEqual(searchScreen.firstPastSearchCell().searchTextView.label, "Political")
    }

}
