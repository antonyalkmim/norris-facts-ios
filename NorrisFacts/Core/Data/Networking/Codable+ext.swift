//
//  Codable+ext.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

struct JSON {
    static var decoder: JSONDecoder {
        JSONDecoder()
    }

    static var encoder: JSONEncoder {
        JSONEncoder()
    }
}
