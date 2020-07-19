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
    
    func test_error_whenListIsEmpty_shouldShowErrorView() {
        factsServiceMocked.syncFactsCategoriesResult = .error(NorrisFactsError.network(.noInternetConnection))
        factsServiceMocked.getFactsResult[""] = .just([])
        
        viewModel.inputs.viewDidAppear.onNext(())
        
        XCTAssertFalse(viewController.errorView.isHidden)
        XCTAssertTrue(viewController.emptyView.isHidden)
        XCTAssertTrue(viewController.errorActionButton.isHidden)
        XCTAssertEqual(viewController.errorMessageLabel.text, L10n.Errors.noInternetConnection)
    }
    
    func test_emptyState_withEmptySearchTerm_shouldShowEmptyView() throws {
        
        let factsToTest = try XCTUnwrap(stub("facts", type: [NorrisFact].self))
            
        // show empty state
        factsServiceMocked.getFactsResult[""] = .just([])
        viewModel.inputs.viewDidAppear.onNext(())
        XCTAssertFalse(viewController.emptyView.isHidden)
        XCTAssertTrue(viewController.tableView.isHidden)
        XCTAssertEqual(viewController.emptyMessageLabel.text, L10n.FactsList.emptyMessage)
        XCTAssertEqual(viewController.emptyImageView.image, Asset.searchBigIcon.image)
        
        // hide empty state
        factsServiceMocked.getFactsResult[""] = .just(factsToTest)
        viewModel.inputs.setCurrentSearchTerm.onNext("")
        XCTAssertTrue(viewController.emptyView.isHidden)
        XCTAssertFalse(viewController.tableView.isHidden)

    }
    
    func test_emptyState_withCurrentSearchTerm_shouldShowWarningEmptyView() {
        
        factsServiceMocked.getFactsResult["something"] = .just([])
        
        viewModel.inputs.viewDidAppear.onNext(())
        viewModel.inputs.setCurrentSearchTerm.onNext("something")
        
        XCTAssertFalse(viewController.emptyView.isHidden)
        XCTAssertTrue(viewController.tableView.isHidden)
        XCTAssertEqual(viewController.emptyMessageLabel.text, L10n.FactsList.emptySearchMessage)
        XCTAssertEqual(viewController.emptyImageView.image, Asset.warning.image)
    }
    
    func test_factCellFontSize_whenShortText_shouldBe23() throws {
        let smallFactStub = stub("fact-short-text", type: NorrisFact.self)
        let smallFact = try XCTUnwrap(smallFactStub, "fact-short-text.json could not be parsed as NorrisFact")
        
        factsServiceMocked.getFactsResult[""] = .just([smallFact])
        viewModel.inputs.viewDidAppear.onNext(())
        
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactTableViewCell
        XCTAssertEqual(cell?.factTextLabel.font.pointSize, 23)
    }
    
    func test_factCellFontSize_whenLongText_shouldBe17() throws {
        let longFactStub = stub("fact-long-text", type: NorrisFact.self)
        let longFact = try XCTUnwrap(longFactStub, "fact-long-text.json could not be parsed as NorrisFact")
        
        factsServiceMocked.getFactsResult[""] = .just([longFact])
        viewModel.inputs.viewDidAppear.onNext(())
        
        let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactTableViewCell
        XCTAssertEqual(cell?.factTextLabel.font.pointSize, 17)
    }
    
    func test_shareFactButtonTap_shouldCallShareScreen() {
        let politicalFacts = stub("facts", type: [NorrisFact].self) ?? []
        factsServiceMocked.getFactsResult[""] = .just(politicalFacts)
        
        let scheduler = TestScheduler(initialClock: 0)
        let shareObserver = scheduler.createObserver(NorrisFact.self)
        
        viewModel.inputs.viewDidAppear.onNext(())
        viewModel.outputs.shareFact
            .subscribe(shareObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let firstCell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FactTableViewCell
        firstCell?.shareFactButton.sendActions(for: .touchUpInside)
        
        let events = shareObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(events.count, 1)
    }

}
