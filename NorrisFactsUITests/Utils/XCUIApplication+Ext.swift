//
//  XCUIApplication+Ext.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 17/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import XCTest

extension XCUIApplication {
    func setLaunchArguments(_ args: [LaunchArgument]) {
        self.launchArguments = args.map { $0.rawValue }
    }
}
