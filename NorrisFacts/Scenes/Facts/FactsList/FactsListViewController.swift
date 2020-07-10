//
//  FactsListViewController.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class FactsListViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    var viewModel: FactsListViewModelType?
    
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorActionButton: UIButton!
    
    @IBOutlet weak var searchFactsButton: UIButton!
    @IBOutlet weak var emptyView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.registerCellWithNib(FactTableViewCell.self)
    }

}

extension FactsListViewController {
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        // Inputs
        
        rx.viewDidAppear
            .bind(to: viewModel.inputs.viewDidAppear)
            .disposed(by: disposeBag)
        
        errorActionButton.rx.tap
            .mapToVoid()
            .bind(to: viewModel.inputs.retryErrorAction)
            .disposed(by: disposeBag)

        searchFactsButton.rx.tap
            .mapToVoid()
            .bind(to: viewModel.inputs.searchButtonAction)
            .disposed(by: disposeBag)
        
        // Outputs
        
        viewModel.outputs.isLoading
            .drive(onNext: { isLoading in
                print("isLoading: \(isLoading)")
            })
            .disposed(by: disposeBag)
        
        let factsViewModels = viewModel.outputs.factsViewModels.share()
        
        factsViewModels.bind { itemsViewModels in
            print("there is \(itemsViewModels.count) items in the list")
        }.disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<FactsSectionViewModel>(
            configureCell: { _, tableView, indexPath, factViewModel -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(type: FactTableViewCell.self, indexPath: indexPath)
                cell.bindViewModel(factViewModel)
                return cell
            }
        )
        
        factsViewModels
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let isFactListEmpty = factsViewModels
            .map { $0.flatMap { $0.items } } // get all items in all sections
            .map { $0.isEmpty }
            .share()
        
        // show empty state
        isFactListEmpty
            .asDriver(onErrorJustReturn: false)
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
            .bind(onNext: { [weak self] errorViewModel in
                self?.bindErrorViewModel(errorViewModel)
            })
            .disposed(by: disposeBag)
        
        // show error toast when list is not empty
        Observable
            .combineLatest(isFactListEmpty, errorViewModel )
            .filter { isListEmpty, _  in !isListEmpty } // list not empty
            .map { _, errorViewModel in errorViewModel }
            .bind {
                print("Show toast for \($0.factListError.localizedDescription)")
            }.disposed(by: disposeBag)
    }
    
    private func showEmptyState(_ isEmptyState: Bool) {
        emptyView.isHidden = !isEmptyState
        errorView.isHidden = isEmptyState
        tableView.isHidden = isEmptyState
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
