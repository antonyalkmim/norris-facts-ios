//
//  FactsListViewController.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit
import RxSwift

class FactsListViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    var viewModel: FactsListViewModelType?
    
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorActionButton: UIButton!
    
    @IBOutlet weak var searchFactsButton: UIButton!
    @IBOutlet weak var emptyView: UIStackView!
    
    init(viewModel: FactsListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    private func setupViews() {
        title = L10n.FactsList.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        errorActionButton.setTitle(L10n.FactsList.retryButton, for: .normal)
    }

}

extension FactsListViewController {
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        rx.viewDidAppear
            .bind(to: viewModel.inputs.viewDidAppear)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isLoading
            .debug("isLoading", trimOutput: true)
            .drive(onNext: { isLoading in
                print("isLoading: \(isLoading)")
            })
            .disposed(by: disposeBag)
        
        errorActionButton.rx.tap
            .mapToVoid()
            .bind(to: viewModel.inputs.retryErrorAction)
            .disposed(by: disposeBag)

        let factsViewModels = viewModel.outputs.factsViewModels.share()
        
        factsViewModels.bind { itemsViewModels in
            print("there is \(itemsViewModels.count) items in the list")
        }.disposed(by: disposeBag)
        
        let isFactListEmpty = factsViewModels
            .map { $0.isEmpty }
            .share()
        
        // show empty state
        isFactListEmpty
            .asDriver(onErrorJustReturn: false)
            .debug("emptyState", trimOutput: true)
            .drive(onNext: { [weak self] isEmpty in
                self?.showEmptyState(isEmpty)
            })
            .disposed(by: disposeBag)
        
        let errorViewModel = viewModel.outputs.errorViewModel.share()
        
        // show error view when empty list
        Observable
            .combineLatest(isFactListEmpty, errorViewModel)
            .filter { isListEmpty, _  in isListEmpty } // empty list
            .map { _, errorViewModel in errorViewModel }
            .debug("error view", trimOutput: true)
            .bind(onNext: { [weak self] errorViewModel in
                self?.bindErrorViewModel(errorViewModel)
            })
            .disposed(by: disposeBag)
        
        // show error toast when list is not empty
        Observable
            .combineLatest(isFactListEmpty, errorViewModel )
            .filter { isListEmpty, _  in !isListEmpty } // list not empty
            .map { _, errorViewModel in errorViewModel }
            .debug("error toast", trimOutput: true)
            .bind {
                print("Show toast for \($0.factListError.localizedDescription)")
            }.disposed(by: disposeBag)
    }
    
    private func showEmptyState(_ isEmptyState: Bool) {
        emptyView.isHidden = !isEmptyState
        errorView.isHidden = isEmptyState
    }
        
    private func bindErrorViewModel(_ errorViewModel: FactListErrorViewModel) {
        errorView.isHidden = false
        emptyView.isHidden = true
        
        switch  errorViewModel.factListError {
        case .syncCategories:
            errorActionButton.isHidden = false
        default:
            errorActionButton.isHidden = true
        }
        
        let error = errorViewModel.factListError.error
        switch error.code {
        case NetworkError.noInternetConnection.code:
            errorMessageLabel.text = L10n.Errors.noInternetConnection
            errorActionButton.setTitle(L10n.FactsList.retryButton, for: .normal)
        default:
            errorMessageLabel.text = L10n.Errors.unknow
        }
        
    }
}
