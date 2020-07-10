//
//  NorrisFactsUITests.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest

class NorrisFactsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShowEmptyViewWhenFirstAccess() throws {
        
        let app = XCUIApplication()
        app.launch()
//        app.launchArguments = ["-reset", "-with-fake-facts"]
        // TODO: tratar launchArguments para:
        // - limpar banco de dados quando passar o arg -reset
        // - salvar dados no database quando passar o arg -with-fake-facts
        
        let emptyViewLabel = app.staticTexts["You haven't seen any Chuck Norris facts yet."]
        XCTAssert(emptyViewLabel.exists)
    }

}
