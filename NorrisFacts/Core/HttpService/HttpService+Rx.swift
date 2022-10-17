//
//  HttpService+Rx.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift

extension HttpService: ReactiveCompatible { }

extension Reactive where Base: HttpServiceType {

    func request(_ endpoint: Base.Target) -> Single<HttpResponse> {
        Single<HttpResponse>.create(subscribe: { [weak base] single in
            let task = base?.request(endpoint) { result in
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    single(.failure(error))
                }
            }

            return Disposables.create { task?.cancel() }
        })
    }
    
}

extension ObservableType where Element == HttpResponse {
    
    /// map current HttpResponse data to an Decodable object
    func map<D: Decodable>(_ type: D.Type, using decoder: JSONDecoder = JSON.decoder) -> Observable<D> {
        flatMap { response -> Observable<D> in
            do {
                
                guard let data = response.data else {
                    return .error(NetworkError.jsonMapping(nil))
                }
                
                let res = try decoder.decode(type, from: data)
                return Observable<D>.just(res)
                
            } catch {
                return Observable<D>.error(NetworkError.jsonMapping(error))
            }
        }
    }
    
    /// Emmits an NetworkError.statusCodeError(statusCode) when current HttpResponse statusCode is in given range
    func errorWhenStatusCode(in range: Range<Int>) -> Observable<HttpResponse> {
        flatMap { response -> Observable<HttpResponse> in
            
            if range.contains(response.statusCode) {
                return .error(NorrisFactsError.network(.statusCodeError(response.statusCode)))
            }
            
            return .just(response)
        }
    }
    
    /// Retry when given HttpResponse statusCode is in range
    func retryWhen(
        statusCode range: Range<Int>,
        maxRetries: Int,
        retryAfter: RxTimeInterval,
        scheduler: SchedulerType = MainScheduler.asyncInstance
    ) -> Observable<Element> {
        errorWhenStatusCode(in: range)
            .retry { errorObservable -> Observable<Int> in
                errorObservable
                    .enumerated()
                    .flatMapLatest { index, err -> Observable<Int> in
                        
                        // check if is network error
                        guard case let NorrisFactsError.network(networkError) = err else {
                            return .error(err)
                        }
                        
                        // check if reach max retries
                        guard index < maxRetries else { throw err }
                        
                        // retry only when NetworkError.statusCodeError
                        if case NetworkError.statusCodeError = networkError {
                            return Observable<Int>.timer(retryAfter, scheduler: scheduler)
                        }
                        
                        return .error(err)
                    }
        }
    }
}
