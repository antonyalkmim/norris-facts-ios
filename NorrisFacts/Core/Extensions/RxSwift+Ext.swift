//
//  RxSwift+Ext.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType {

    func mapToVoid() -> Observable<Void> {
        map { _ in Void() }
    }
}

extension ObservableType where Element: EventConvertible {

    /**
     Returns an observable sequence containing only next elements from its input
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     */
    public func elements() -> Observable<Element.Element> {
        return compactMap { $0.event.element }
    }

    /**
     Returns an observable sequence containing only error elements from its input
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     */
    public func errors() -> Observable<Swift.Error> {
        return compactMap { $0.event.error }
    }
}
