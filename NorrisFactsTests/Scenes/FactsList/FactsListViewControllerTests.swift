//
//  FactsListViewControllerTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import NorrisFacts

class FactsListViewControllerTests: XCTestCase {

    var viewController: FactsListViewController!
    var viewModel: FactsListViewModelType!
    var factsServiceMocked: NorrisFactsServiceMocked!
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
        
        factsServiceMocked = NorrisFactsServiceMocked()
        viewModel = FactsListViewModel(factsService: factsServiceMocked)
        viewController = FactsListViewController(viewModel: viewModel)
        _ = viewController.view
    }
    
    override func tearDown() {
        disposeBag = nil
        factsServiceMocked = nil
        viewModel = nil
    }
    
    func testSyncCategoriesError() {
        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))
        viewModel.inputs.viewDidAppear.onNext(())
        
        XCTAssertFalse(viewController.errorView.isHidden)
        XCTAssertFalse(viewController.errorActionButton.isHidden)
        XCTAssertEqual(viewController.errorMessageLabel.text, L10n.Errors.noInternetConnection)
    }

}
