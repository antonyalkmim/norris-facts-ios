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
            .bind(to: viewModel.inputs.syncCategories)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.errorView.isHidden = isLoading
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.errorViewModel
            .bind(onNext: { [weak self] errorViewModel in
                self?.bindErrorViewModel(errorViewModel)
            })
            .disposed(by: disposeBag)
        
        errorActionButton.rx.tap
            .mapToVoid()
            .bind(to: viewModel.inputs.syncCategories)
            .disposed(by: disposeBag)

    }
        
    private func bindErrorViewModel(_ errorViewModel: FactListErrorViewModel) {
        
        errorActionButton.isHidden = !errorViewModel.isRetryEnabled
        
        let error = errorViewModel.error
        switch error.code {
        case NetworkError.noInternetConnection.code:
            errorMessageLabel.text = L10n.Errors.noInternetConnection
            errorActionButton.setTitle(L10n.FactsList.retryButton, for: .normal)
        default:
            errorMessageLabel.text = L10n.Errors.unknow
        }
        
    }
}
