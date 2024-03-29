//
//  HttpService.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation

protocol TargetType {
    /// API host
    var baseURL: URL { get }
    /// endpoint path
    var path: String { get }
    /// HTTP method
    var method: HttpMethod { get }
    /// HTTP json body
    var body: Data? { get }
    /// HTTP headers
    var headers: [String: String]? { get }
    /// Mocked data. If `sampleData` is not nil, it will not execute the request and will return the sample data instead
    var sampleData: HttpResponse? { get }
}

extension TargetType {
    func urlRequest() -> URLRequest {

        // generate url
        let pathComponents = path.split(separator: "?")
        let pathQueries = pathComponents
            .dropFirst()
            .joined(separator: "?")
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let pathFormatted = String(pathComponents.first ?? "")
            .appending("?")
            .appending(pathQueries ?? "")

        guard let url = URLComponents(string: "\(baseURL.absoluteString)\(pathFormatted)")?.url else {
            fatalError("invalid URL")
        }

        var request = URLRequest(url: url)

        /// http method
        request.httpMethod = self.method.rawValue

        /// request body
        request.httpBody = self.body

        /// headers
        self.headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        return request
    }
}

extension TargetType {
    func bodyPayload(_ dictionary: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
    }
    
    func bodyPayload<T: Encodable>(_ object: T) -> Data? {
        return try? JSON.encoder.encode(object)
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct HttpResponse {
    let statusCode: Int
    let data: Data?
}

protocol HttpServiceType: AnyObject {
    
    /// Completion handler for requests
    typealias RequestCompletionHandler = (Result<HttpResponse, NorrisFactsError>) -> Void
    
    associatedtype Target: TargetType
    
    /// Execute a request for a given endpoint target
    func request(_ endpoint: Target, completion: @escaping RequestCompletionHandler) -> URLSessionDataTask?
}

class HttpService<Target: TargetType>: HttpServiceType {

    /// closure executed before request
    typealias RequestClosure = (Target) -> URLRequest

    /// closure executed after response
    typealias ResponseClosure = (HTTPURLResponse?, Data?) -> Void
    
    var requestClosure: RequestClosure
    var responseClosure: ResponseClosure
    private let session: URLSession

    // MARK: - Initializer
    init(urlSession: URLSession? = nil,
         requestClosure: @escaping RequestClosure = { $0.urlRequest() },
         responseClosure: @escaping ResponseClosure = { _, _ in }) {

        self.session = urlSession ?? URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: nil
        )
        self.requestClosure = requestClosure
        self.responseClosure = responseClosure
    }

    @discardableResult
    func request(_ endpoint: Target, completion: @escaping RequestCompletionHandler) -> URLSessionDataTask? {
        
        //1 - pass through interceptors
        let request = requestClosure(endpoint)

        //2 - execute task
        // sample data
        if let sampleData = endpoint.sampleData {
            completion(.success(sampleData))
            return nil
        }

        // reachability
        if !Reachability.isConnectedToNetwork {
            completion(.failure(.network(.noInternetConnection)))
            return nil
        }

        // real request
        let task = self.session.dataTask(with: request) { [weak self] data, response, error in
            
            if let err = error {
                completion(.failure(.network(.unknow(err))))
                return
            }
            
            guard let httpURLResponse = response as? HTTPURLResponse else {
                completion(.failure(.network(.connectionError)))
                return
            }
            
            // run interceptors for response
            self?.responseClosure(httpURLResponse, data)

            let httpResponse = HttpResponse(
                statusCode: httpURLResponse.statusCode,
                data: data
            )
            
            completion(.success(httpResponse))
        }
        task.resume()

        //3 - return task
        return task
    }

}
