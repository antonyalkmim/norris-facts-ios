//
//  SearchFactViewControllerTests.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 14/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest

@testable import NorrisFacts

class SearchFactViewControllerTests: XCTestCase {

    var viewController: SearchFactViewController!
    var viewModel: SearchFactViewModelType!
    var factsServiceMocked: NorrisFactsServiceMocked!
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        disposeBag = DisposeBag()
        
        factsServiceMocked = NorrisFactsServiceMocked()
        viewModel = SearchFactViewModel(factsService: factsServiceMocked)
        viewController = SearchFactViewController(viewModel: viewModel)
        _ = viewController.view
    }
    
    override func tearDown() {
        disposeBag = nil
        factsServiceMocked = nil
        viewModel = nil
        viewController = nil
    }
    
    func test_pastSearches_whenEmpty_shouldBeHidden() {
        factsServiceMocked.getPastSearchTermsResult = .just([])
        
        viewModel.inputs.viewWillAppear.onNext(())
        
        XCTAssertTrue(viewController.tableView.isHidden)
        XCTAssertTrue(viewController.pastSearchLabel.isHidden)
    }
    
    func test_pastSearches_shouldListItems() {
        factsServiceMocked.getPastSearchTermsResult = .just(["political", "sport"])
        
        viewModel.inputs.viewWillAppear.onNext(())
        
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertFalse(viewController.tableView.isHidden)
        XCTAssertFalse(viewController.pastSearchLabel.isHidden)
    }
    
    func test_suggestionsView_shouldPresentUpTo8Items() {
        let testCategories = stub("get-categories", type: [FactCategory].self) ?? []
        factsServiceMocked.getCategoriesResult = .just(testCategories)
        
        viewModel.inputs.viewWillAppear.onNext(())
        
        XCTAssertEqual(viewController.tagsCollectionView.numberOfItems(inSection: 0), 8)
    }
    
}
