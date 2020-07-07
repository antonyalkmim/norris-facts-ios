//
//  FactsListCoordinator.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit

class FactsListCoordinator: Coordinator {
    
    let window: UIWindow
    var navigationController: UINavigationController?
    var factsListViewController: FactsListViewController?
    var factsListViewModel: FactsListViewModelType?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let viewModel = FactsListViewModel()
        factsListViewModel = viewModel
        
        let viewController = FactsListViewController(viewModel: viewModel)
        factsListViewController = viewController
        
        navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func stop() {
        navigationController = nil
        factsListViewController = nil
    }
}
