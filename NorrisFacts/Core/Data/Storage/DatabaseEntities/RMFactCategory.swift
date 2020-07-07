//
//  RMFactCategory.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RealmSwift

class RMFactCategory: Object {
    @objc dynamic var title: String = ""
    
    override static func primaryKey() -> String? {
        return "title"
    }
}

// Adapter
extension RMFactCategory {
    convenience init(category: FactCategory) {
        self.init(value: [
            "title": category.title
        ])
    }
    
    var object: FactCategory {
        return FactCategory(title: "title")
    }
}
