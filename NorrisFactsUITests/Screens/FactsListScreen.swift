//
//  FactsListScreen.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 17/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import XCTest

struct FactsListScreen {
    
    private struct ElementID {
        static let kFactsTableView = "facts_table_view"
        static let kSearchBarButtonItem = "search_bar_button_item"
        static let kEmptyView = "empty_view"
        static let kEmptyViewLabel = "empty_view_label"
        static let kEmptyViewButton = "empty_view_button"
        static let kCurrentSearchView = "current_search_view"
        static let kCurrentSearchLabel = "current_search_label"
        static let kClearSearchButton = "clear_search_button"
        static let kToastView = "toast_view"
    }
    
    let factsTableView: XCUIElement
    let searchBarButtonItem: XCUIElement
    
    let emptyView: XCUIElement
    let emptyViewLabel: XCUIElement
    let emptyViewButton: XCUIElement
    
    let currentSearchTermView: XCUIElement
    let currentSearchLabel: XCUIElement
    let clearSearchButton: XCUIElement
    
    let toastView: XCUIElement
    
    init() {
        let app = XCUIApplication()
        
        factsTableView = app.tables[ElementID.kFactsTableView]
        searchBarButtonItem = app.navigationBars.buttons[ElementID.kSearchBarButtonItem]
        
        emptyView = app.otherElements[ElementID.kEmptyView]
        emptyViewLabel = app.staticTexts[ElementID.kEmptyViewLabel]
        emptyViewButton = app.buttons[ElementID.kEmptyViewButton]
        
        currentSearchTermView = app.otherElements[ElementID.kCurrentSearchView]
        currentSearchLabel = app.staticTexts[ElementID.kCurrentSearchLabel]
        clearSearchButton = app.buttons[ElementID.kClearSearchButton]
        
        toastView = app.otherElements[ElementID.kToastView]
    }
    
    func firstCell() -> FactListCellElement {
        FactListCellElement(element: factsTableView.cells.firstMatch)
    }
    
}

struct FactListCellElement {
    
    private struct ElementID {
        static let kShareButton = "fact_cell_share_button"
    }
    
    let element: XCUIElement
    let shareButton: XCUIElement
    
    init(element: XCUIElement) {
        self.element = element
        self.shareButton = element.buttons[ElementID.kShareButton]
    }
    
}
