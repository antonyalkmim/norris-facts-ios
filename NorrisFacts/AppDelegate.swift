//
//  AppDelegate.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    var disposeBag = DisposeBag()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        processLaunchArguments()
        setupAppearence()
        
        window = UIWindow()
        appCoordinator = AppCoordinator(window: window ?? UIWindow())
        appCoordinator?.start()
            .subscribe()
            .disposed(by: disposeBag)
        
        return true
    }
    
    private func setupAppearence() {
        UINavigationBar.appearance().tintColor = .black
    }

}
