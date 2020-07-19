//
//  FactsListCoordinator.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class FactsListCoordinator: Coordinator<Void> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel = FactsListViewModel()
        let factsListViewController = FactsListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: factsListViewController)
    
        viewModel.outputs.showSearchFactForm
            .flatMap { [weak self] _ -> Observable<String?> in
                guard let `self` = self else { return .empty() }
                return self.showSearchForm(on: factsListViewController)
            }
            .filter { $0 != nil }
            .compactMap { $0 }
            .bind(to: viewModel.inputs.setCurrentSearchTerm)
            .disposed(by: disposeBag)
        
        viewModel.shareFact
            .bind(onNext: { [weak self] fact in
                self?.showShareActivity(for: fact, in: factsListViewController)
            })
            .disposed(by: disposeBag)
            
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return .never()
    }
    
    private func showSearchForm(on rootViewController: UIViewController) -> Observable<String?> {
        let searchCoordinator = SearchFactCoordinator(rootViewController: rootViewController)
        return coordinate(to: searchCoordinator)
            .map { result in
                switch result {
                case .searchTerm(let term):
                    return term
                case .cancel:
                    return nil
                }
            }
    }
    
    private func showShareActivity(for fact: NorrisFact, in viewController: UIViewController) {
        var activityItems: [Any] = [fact.text]
        
        if let factUrl = URL(string: fact.url) {
            activityItems.append(factUrl)
        }
        
        let shareActivity = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        viewController.present(shareActivity, animated: true, completion: nil)
    }

}
