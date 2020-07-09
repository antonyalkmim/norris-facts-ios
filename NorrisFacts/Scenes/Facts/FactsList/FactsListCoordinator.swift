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
        let factsListViewController = FactsListViewController()
        let navigationController = UINavigationController(rootViewController: factsListViewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return .never()
    }

}
