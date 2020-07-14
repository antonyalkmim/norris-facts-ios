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
    var sampleData: Data? { get }
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

protocol HttpServiceType: class {
    associatedtype Target: TargetType
    var session: URLSession { get }
    func request(_ endpoint: Target, responseData: @escaping (Result<Data, NorrisFactsError>) -> Void) -> URLSessionDataTask?
}

class HttpService<Target: TargetType>: HttpServiceType {

    /// closure executed before request
    typealias RequestClosure = (Target) -> URLRequest

    /// closure executed after response
    typealias ResponseClosure = (HTTPURLResponse?, Data?) -> Void

    private var requestClosure: RequestClosure
    private var responseClosure: ResponseClosure
    public let session: URLSession

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
    func request(_ endpoint: Target, responseData: @escaping (Result<Data, NorrisFactsError>) -> Void) -> URLSessionDataTask? {
        //1 - pass through interceptors
        let request = requestClosure(endpoint)

        //2 - execute task
        // sample data
        if let sampleData = endpoint.sampleData {
            responseData(Result.success(sampleData))
            return nil
        }

        // reachability
        if !Reachability.isConnectedToNetwork {
            responseData(Result.failure(.network(.noInternetConnection)))
            return nil
        }

        // real request
        let task = self.session.dataTask(with: request) { [weak self] data, response, error in

            if let err = error {
                responseData(Result.failure(.network(.unknow(err))))
                return
            }

            let httpResponse = response as? HTTPURLResponse
            self?.responseClosure(httpResponse, data)

            guard let data = data else {
                responseData(Result.failure(.network(.connectionError)))
                return
            }
            responseData(Result.success(data))
        }
        task.resume()

        //3 - return task
        return task
    }

}
