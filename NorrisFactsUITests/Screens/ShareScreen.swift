//
//  ShareScreen.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 17/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import XCTest

struct ShareScreen {
    
    private struct ElementID {
        static let kActivityList = "ActivityListView"
        static let kCloseButton = "Close"
    }
    
    let activityList: XCUIElement
    let closeButton: XCUIElement
    
    init() {
        let app = XCUIApplication()
        activityList = app.otherElements[ElementID.kActivityList]
        closeButton = activityList.buttons[ElementID.kCloseButton]
    }
}
