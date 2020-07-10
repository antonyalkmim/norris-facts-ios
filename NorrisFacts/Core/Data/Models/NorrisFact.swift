//
//  NorrisFact.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

struct NorrisFact: Decodable {
    let id: String
    let text: String
    let iconUrl: String
    let createdAt: Date
    let updatedAt: Date
    let categories: [FactCategory]
    
    enum CodingKeys: String, CodingKey {
        case id
        case text = "value"
        case iconUrl
        case createdAt
        case updatedAt
        case categories
    }
}

extension NorrisFact: Equatable { }
func == (lhs: NorrisFact, rhs: NorrisFact) -> Bool {
    return lhs.id == rhs.id
}
