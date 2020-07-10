//
//  FactsListCoordinator.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class FactsListCoordinator: Coordinator<Void> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel = FactsListViewModel()
        let factsListViewController = FactsListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: factsListViewController)
    
        viewModel.outputs.showSearchFactForm
            .flatMap { [weak self] _ -> Observable<String?> in
                guard let `self` = self else { return .empty() }
                return self.showSearchForm()
            }
            .filter { $0 != nil }
            .compactMap { $0 }
            .bind(to: viewModel.inputs.setCurrentSearchTerm)
            .disposed(by: disposeBag)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return .never()
    }
    
    private func showSearchForm() -> Observable<String?> {
        .just("political")
    }

}
