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
        viewController = nil
    }
    
    func testShowErrorViewWhenListIsEmpty() {
        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))
        factsServiceMocked.getFactsResult[""] = .just([])
        
        viewModel.inputs.viewDidAppear.onNext(())
        
        XCTAssertFalse(viewController.errorView.isHidden)
        XCTAssertTrue(viewController.emptyView.isHidden)
        XCTAssertTrue(viewController.errorActionButton.isHidden)
        XCTAssertEqual(viewController.errorMessageLabel.text, L10n.Errors.noInternetConnection)
    }
    
    func testEmptyState() {
        let factsToTest = stub("facts", type: [NorrisFact].self) ?? []
            
        factsServiceMocked.getFactsResult[""] = .just([])
        viewModel.inputs.viewDidAppear.onNext(())
        XCTAssertFalse(viewController.emptyView.isHidden)
        XCTAssertTrue(viewController.tableView.isHidden)
        
        factsServiceMocked.getFactsResult[""] = .just(factsToTest)
        viewModel.inputs.viewDidAppear.onNext(())
        XCTAssertTrue(viewController.emptyView.isHidden)
        XCTAssertFalse(viewController.tableView.isHidden)
    }
    
    func testFactCellFontSizeWithShortText() {
        guard let factShortText = stub("fact-short-text", type: NorrisFact.self) else {
            XCTFail("Fact should not be nil")
            return
        }
        factsServiceMocked.getFactsResult[""] = .just([factShortText])
        viewModel.inputs.viewDidAppear.onNext(())
        
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactTableViewCell
        XCTAssertEqual(cell?.factTextLabel.font.pointSize, 23)
    }
    
    func testFactCellFontSizeWithLongText() {
        guard let factLongText = stub("fact-long-text", type: NorrisFact.self) else {
            XCTFail("Fact should not be nil")
            return
        }
        factsServiceMocked.getFactsResult[""] = .just([factLongText])
        viewModel.inputs.viewDidAppear.onNext(())
        
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactTableViewCell
        XCTAssertEqual(cell?.factTextLabel.font.pointSize, 17)
    }

}
