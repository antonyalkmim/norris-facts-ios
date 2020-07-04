//
//  NorricsFactsStorage.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift

protocol NorrisFactsStorageType {
    func insert() -> Single<Void>
}

class NorrisFactsStorage: NorrisFactsStorageType {
    
    func insert() -> Single<Void> {
        .just(())
    }
    
}
