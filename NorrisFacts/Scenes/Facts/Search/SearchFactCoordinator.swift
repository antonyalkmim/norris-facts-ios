//
//  SearchFactCoordinator.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 11/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum SearchFactCoordinatorResult {
    case searchTerm(String)
    case cancel
}

final class SearchFactCoordinator: Coordinator<SearchFactCoordinatorResult> {
    
    private let rootViewController: UIViewController
    
    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<SearchFactCoordinatorResult> {
        let viewModel = SearchFactViewModel()
        let searchViewController = SearchFactViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: searchViewController)
        
        let didSelectSearchTerm = viewModel.outputs.didSelectSearchTerm
            .map { SearchFactCoordinatorResult.searchTerm($0) }
        
        let cancelSearch = viewModel.outputs.didCancelSearch
            .map { SearchFactCoordinatorResult.cancel }
        
        rootViewController.present(navigationController, animated: true)
        
        return Observable.merge(didSelectSearchTerm, cancelSearch)
            .take(1)
            .observe(on: MainScheduler.instance)
            .do(onNext: { _ in navigationController.dismiss(animated: true) })
    }

}
