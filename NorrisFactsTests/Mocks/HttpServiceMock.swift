//
//  HttpServiceMock.swift
//  NorrisFactsTests
//
//  Created by Antony Nelson Daudt Alkmim on 18/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
@testable import NorrisFacts

final class HttpServiceMock: HttpService<NorrisFactsAPI> {
    
    var responseResult: Result<HttpResponse, NorrisFactsError>?
    
    override func request(_ endpoint: NorrisFactsAPI, completion: @escaping RequestCompletionHandler) -> URLSessionDataTask? {
        completion(responseResult ?? .failure(.unknow(nil)))
        return nil
    }
    
    func mockRequest(statusCode: Int = 200, _ data: Data?) {
        let httpResponse = HttpResponse(statusCode: statusCode, data: data)
        self.responseResult = .success(httpResponse)
    }
    
}
