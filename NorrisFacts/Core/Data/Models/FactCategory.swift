//
//  FactCategory.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

struct FactCategory: Decodable {
    let title: String

    init(title: String) {
        self.title = title
    }
    
    init(from decoder: Decoder) throws {
        self.title = try decoder
            .singleValueContainer()
            .decode(String.self)
    }
}
