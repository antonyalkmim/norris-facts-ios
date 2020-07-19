//
//  LaunchArguments.swift
//  NorrisFactsUITests
//
//  Created by Antony Nelson Daudt Alkmim on 17/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

enum LaunchArgument: String {
    
    /// flag indicates that is running on UI tests
    case uiTest = "--ui-testing"
    
    /// flag to clear database and userDefaults data
    case resetEnviroments = "--reset-env"
    
    /// flag to use fake data on API requests
    case useMockHttpRequests = "--mock-api-requests"
    
    /// flag to use fake errors data on API requests
    case useMockErrorHttpRequests = "--mock-error-api-requests"
    
    /// flag to use fake data on API requests
    case useMockDatabase = "--mock-database"
}
