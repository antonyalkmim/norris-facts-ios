//
//  NorrisFactsAPI.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

enum NorrisFactsAPI {
    case search(term: String)
}

extension NorrisFactsAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.chucknorris.io")!
    }

    var path: String {
        switch self {
        case .search:
            return ""
        }
    }

    var method: HttpMethod {
        switch self {
        case .search:
            return .post
        }
    }

    var body: Data? {
        switch self {
        case .search:
            return nil
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var sampleData: Data {
        return Data()
    }

}
