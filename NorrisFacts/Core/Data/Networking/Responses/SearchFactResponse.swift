//
//  SearchFactResponse.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 09/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

struct SearchFactResponse: Decodable {
    let total: Int
    let facts: [NorrisFact]
    
    enum CodingKeys: String, CodingKey {
        case total
        case facts = "result"
    }
}
