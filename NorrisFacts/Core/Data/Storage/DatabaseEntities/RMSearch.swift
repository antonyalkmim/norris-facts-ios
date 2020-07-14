//
//  RMSearchTerm.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 10/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//
import Foundation
import RealmSwift

class RMSearch: Object {
    @objc dynamic var term: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    let facts = List<RMNorrisFact>()
    
    override static func primaryKey() -> String? {
        return "term"
    }
}

// Adapter
extension RMSearch {
    convenience init(term: String, facts: [NorrisFact]) {
        self.init(value: [
            "term": term,
            "createdAt": Date(),
            "updatedAt": Date(),
            "facts": facts.map(RMNorrisFact.init)
        ])
    }
}
