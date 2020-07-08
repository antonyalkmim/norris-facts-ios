//
//  Codable+ext.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

public struct JSON {
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd_HHmmssSSSS)
        return decoder
    }

    public static var encoder: JSONEncoder {
        JSONEncoder()
    }
}
