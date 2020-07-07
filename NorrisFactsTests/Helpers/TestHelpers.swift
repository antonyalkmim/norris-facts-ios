//
//  TestHelpers.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import XCTest
@testable import NorrisFacts

class TestHelper { }

extension XCTestCase {
    func stub<T: Decodable>(_ filename: String, type parseType: T.Type, decoder: JSONDecoder = JSON.decoder) -> T? {
        let bundle = Bundle(for: type(of: self))
        guard let fileUrl = bundle.url(forResource: filename, withExtension: ".json") else { return nil }
        
        do {
            let data = try Data(contentsOf: fileUrl)
            let value = try decoder.decode(parseType, from: data)
            return value
        } catch {
            return nil
        }
    }

}
