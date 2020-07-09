//
//  BaseCoordinator.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift

class Coordinator<ResultType> {
    
    typealias CoordinatorResult = ResultType
    
    let disposeBag = DisposeBag()
    
    private let identifier = UUID()
    
    private var childCoordinators = [UUID: Any]()
    
    private func store<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }
    
    private func free<T>(coordinator: Coordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
    
    func coordinate<T>(to coordinator: Coordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start().do(onNext: { [weak self] _ in
            self?.free(coordinator: coordinator)
        })
    }
    
    func start() -> Observable<ResultType> {
        fatalError("This method should be override by subclasses")
    }
    
}
