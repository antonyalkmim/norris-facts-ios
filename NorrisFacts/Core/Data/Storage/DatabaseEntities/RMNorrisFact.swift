//
//  RMFact.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RealmSwift

class RMNorrisFact: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var iconUrl: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()
    let categories = List<RMFactCategory>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Adapter
extension RMNorrisFact {
    convenience init(fact: NorrisFact) {
        self.init(value: [
            "id": fact.id,
            "text": fact.text,
            "iconUrl": fact.iconUrl,
            "createdAt": fact.createdAt,
            "updatedAt": fact.updatedAt,
            "categories": fact.categories.map(RMFactCategory.init)
        ])
    }
    
    var object: NorrisFact {
        return NorrisFact(
            id: id,
            text: text,
            iconUrl: iconUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            categories: categories.map { $0.object }
        )
    }
}

