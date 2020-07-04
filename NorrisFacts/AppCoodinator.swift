//
//  AppCoodinator.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    
    let window: UIWindow
        
    // Child coordinators
    var fatcsListCoordinator: FactsListCoordinator?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        fatcsListCoordinator = FactsListCoordinator(window: window)
        fatcsListCoordinator?.start()
    }
    
    func stop() {
        fatcsListCoordinator = nil
    }

}
