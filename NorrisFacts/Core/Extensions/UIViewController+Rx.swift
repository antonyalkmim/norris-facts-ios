//
//  UIViewController+Rx.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 06/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension Reactive where Base: UIViewController {
    var viewDidAppear: Observable<Void> {
        sentMessage(#selector(Base.viewDidAppear(_:)))
            .mapToVoid()
    }
}
