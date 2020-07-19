//
//  NorrisFactsAPI.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

enum NorrisFactsAPI {
    case getCategories
    case search(term: String)
}

extension NorrisFactsAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://api.chucknorris.io/jokes")!
    }

    var path: String {
        switch self {
        case .getCategories:
            return "/categories"
        case .search(let term):
            return "/search?query=\(term)"
        }
    }

    var method: HttpMethod {
        switch self {
        case .getCategories, .search:
            return .get
        }
    }

    var body: Data? {
        switch self {
        case .getCategories, .search:
            return nil
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var sampleData: HttpResponse? {
        
        if LaunchArgument.check(.useMockHttpRequests) {
            return mockHttpRequest()
        }
        
        if LaunchArgument.check(.useMockErrorHttpRequests) {
            return mockErrorHttpRequest()
        }
        
        return nil
    }

    private func mockHttpRequest() -> HttpResponse {
        switch self {
        case .getCategories:
            return HttpResponse(statusCode: 200,
                                data: stub("get-categories"))
        case .search:
            return HttpResponse(statusCode: 200,
                                data: stub("search-facts"))
        }
    }
    
    private func mockErrorHttpRequest() -> HttpResponse {
        HttpResponse(statusCode: 200, data: nil)
    }
}
