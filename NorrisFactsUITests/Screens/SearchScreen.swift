//
//  SearchScreen.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 17/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import XCTest

struct SearchScreen {
    
    private struct ElementID {
        static let kSuggestionsCollectionView = "suggestions_view"
        static let kPastSearchTableView = "past_searches_view"
    }
    
    let searchBarField: XCUIElement
    let suggestionsCollectionView: XCUIElement
    let pastSearchTableView: XCUIElement
    
    init() {
        let app = XCUIApplication()
        searchBarField = app.searchFields.element
        suggestionsCollectionView = app.collectionViews[ElementID.kSuggestionsCollectionView]
        pastSearchTableView = app.tables[ElementID.kPastSearchTableView]
    }
    
    func firstSuggestionCell() -> SuggestionCellElement {
        SuggestionCellElement(element: suggestionsCollectionView.cells.firstMatch)
    }
    
    func firstPastSearchCell() -> PastSearchCellElement {
        PastSearchCellElement(element: pastSearchTableView.cells.firstMatch)
    }
}

struct SuggestionCellElement {
    
    let element: XCUIElement
    let tagTextView: XCUIElement
    
    init(element: XCUIElement) {
        self.element = element
        self.tagTextView = element.staticTexts.firstMatch
    }
}

struct PastSearchCellElement {
    
    let element: XCUIElement
    let searchTextView: XCUIElement
    
    init(element: XCUIElement) {
        self.element = element
        self.searchTextView = element.staticTexts.firstMatch
    }
}
