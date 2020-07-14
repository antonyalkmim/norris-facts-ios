//
//  AppDelegate+LaunchArguments.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 10/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RealmSwift

enum LaunchArgument: String {
    
    /// flag indicates that is running on UI tests
    case uiTest = "--ui-testing"
    
    /// flat to clear database and userDefaults data
    case resetEnviroments = "--reset-env"
    
    /// flag to use fake data on API requests
    case useMockHttpRequests = "--mock-api-requests"
    
    /// flag to use fake data on API requests
    case useMockDatabase = "--mock-database"
    
    static func check(_ argument: LaunchArgument) -> Bool {
        CommandLine.arguments.contains(argument.rawValue)
    }
}

extension AppDelegate {
    
    func processLaunchArguments() {
        
        if LaunchArgument.check(.uiTest) {
            UIView.setAnimationsEnabled(false)
        }
        
        if LaunchArgument.check(.resetEnviroments) {
            let realm = try? Realm()
            try? realm?.write {
                realm?.deleteAll()
            }
        }
        
        if LaunchArgument.check(.useMockDatabase) {
            let realm = try? Realm()
            try? realm?.write {
                
                let sportFacts = stub("sport-facts", type: [NorrisFact].self) ?? []
                let politicalFacts = stub("political-facts", type: [NorrisFact].self) ?? []
                
                // save 2 searches
                let searches = [
                    RMSearch(term: "sport", facts: sportFacts),
                    RMSearch(term: "political", facts: politicalFacts)
                ]
                
                realm?.add(searches, update: .modified)
            }
        }
                
    }
}
