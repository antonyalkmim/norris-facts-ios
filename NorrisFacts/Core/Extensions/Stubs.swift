//
//  Data+ext.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 10/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

func stub<T: Decodable>(_ filename: String, type parseType: T.Type, decoder: JSONDecoder = JSON.decoder) -> T? {
    
    guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: ".json") else {
        return nil
    }
    
    do {
        let data = try Data(contentsOf: fileUrl)
        let value = try decoder.decode(parseType, from: data)
        return value
    } catch {
        return nil
    }
}

func stub(_ filename: String) -> Data? {
    
    guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: ".json") else {
        return nil
    }
    
    return try? Data(contentsOf: fileUrl)
}
