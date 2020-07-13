//
//  FactsListErrorViewModelTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 11/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest
import RealmSwift

@testable import NorrisFacts

class FactsListErrorViewModelTests: XCTestCase {
    
    var viewModel: FactListErrorViewModel!
    
    override func tearDown() {
        viewModel = nil
    }
    
    func testLoadFactsNoInternetConnectionError() {
        viewModel = FactListErrorViewModel(factListError: .loadFacts(NetworkError.noInternetConnection))
        XCTAssertEqual(viewModel.errorMessage, L10n.Errors.noInternetConnection)
        XCTAssertEqual(viewModel.isRetryEnabled, false)
        XCTAssertEqual(viewModel.iconImage, Asset.wifiError.image)
    }
    
    func testLoadFactsConnectionError() {
        viewModel = FactListErrorViewModel(factListError: .loadFacts(NetworkError.connectionError))
        XCTAssertEqual(viewModel.errorMessage, L10n.Errors.unknow)
        XCTAssertEqual(viewModel.isRetryEnabled, true)
        XCTAssertEqual(viewModel.iconImage, Asset.warning.image)
    }
}
