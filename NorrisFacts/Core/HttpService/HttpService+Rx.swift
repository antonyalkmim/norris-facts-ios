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

    func request(_ endpoint: Base.Target) -> Single<Data> {
        return Single<Data>
            .create(subscribe: { [weak base] single in
                let task = base?.request(endpoint, responseData: { result in
                    switch result {
                    case Result.success(let data):
                        single(SingleEvent.success(data))
                    case Result.failure(let error):
                        single(SingleEvent.error(error))
                    }
                })

                return Disposables.create { task?.cancel() }
            })
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Data {
    
    public func map<D: Decodable>(_ type: D.Type, using decoder: JSONDecoder = JSON.decoder) -> Single<D> {
        flatMap { data in
            do {
                let res = try decoder.decode(type, from: data)
                return Single<D>.just(res)
            } catch {
                return Single<D>.error(NetworkError.jsonMapping(error))
            }
        }
    }
}
