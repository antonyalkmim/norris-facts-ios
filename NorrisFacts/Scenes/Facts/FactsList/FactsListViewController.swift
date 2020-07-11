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
import Lottie

class FactsListViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    var viewModel: FactsListViewModelType?
    
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorActionButton: UIButton!
    @IBOutlet weak var errorImageView: UIImageView!
    
    @IBOutlet weak var searchFactsButton: UIButton!
    @IBOutlet weak var emptyView: UIStackView!
    
    @IBOutlet weak var searchTermView: UIView!
    @IBOutlet weak var searchTermLabel: UILabel!
    @IBOutlet weak var clearSearchButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopSafeAreaConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingView: AnimationView!
    
    let searchBarButtonItem = UIBarButtonItem.init(image: Asset.searchIcon.image,
                                                   style: .plain,
                                                   target: nil,
                                                   action: nil)
    
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
        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        errorActionButton.setTitle(L10n.FactsList.retryButton, for: .normal)
        
        searchTermView.layer.cornerRadius = 16
        
        loadingView.animation = Animation.named("loading-blue")
        loadingView.loopMode = .loop
        
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
        
        clearSearchButton.rx.tap
            .map { "" }
            .bind(to: viewModel.inputs.setCurrentSearchTerm)
            .disposed(by: disposeBag)
        
        // show search form screen
        let searchButtonTap = searchFactsButton.rx.tap.mapToVoid()
        let searchBarButtonItemTap = searchBarButtonItem.rx.tap.mapToVoid()
        
        Observable.merge(searchButtonTap, searchBarButtonItemTap)
            .bind(to: viewModel.inputs.searchButtonAction)
            .disposed(by: disposeBag)
        
        // Outputs
        
        viewModel.outputs.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.showLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentSearchTerm
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] currentTerm in
                self?.bindCurrentSearchTerm(currentTerm)
            })
            .disposed(by: disposeBag)
        
        let factsViewModels = viewModel.outputs.factsViewModels.share()
        
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
            .observeOn(MainScheduler.instance)
            .bind { [weak self] errorViewModel in
                self?.showToast(text: errorViewModel.errorMessage)
            }.disposed(by: disposeBag)
    }
    
    private func showEmptyState(_ isEmptyState: Bool) {
        emptyView.isHidden = !isEmptyState
        errorView.isHidden = isEmptyState
        tableView.isHidden = isEmptyState
    }
    
    private func showLoading(_ isLoading: Bool) {
        loadingView.isHidden = !isLoading
        
        if isLoading {
            errorView.isHidden = true
            emptyView.isHidden = true
            
            loadingView.play()
        } else {
            loadingView.stop()
        }
    }
    
    private func bindCurrentSearchTerm(_ currentTerm: String) {

        searchTermLabel.text = currentTerm.capitalized
        
        // Show animation should start with searchView visible and out of screen
        // Hide animation should start with searchView visible and hide when complete the animation
        if !currentTerm.isEmpty {
            self.searchTermView.isHidden = false
        }
        
        // animate the tableview top constraint to have place for searchTermView appears
        // and animate the searchView translation from left side of screen to inside the screen
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            let currentTableViewTopConstraint: CGFloat = currentTerm.isEmpty ? 0 : 58
            self.tableViewTopSafeAreaConstraint.constant = currentTableViewTopConstraint
            
            let searchViewWidth = self.searchTermView.frame.width
            let currentSearchViewLeadingConstraint: CGFloat = currentTerm.isEmpty ? -searchViewWidth : 16
            self.searchViewLeadingConstraint.constant = currentSearchViewLeadingConstraint
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.searchTermView.isHidden = currentTerm.isEmpty
        })
        
    }
        
    private func bindErrorViewModel(_ errorViewModel: FactListErrorViewModel) {
        errorView.isHidden = false
        emptyView.isHidden = true
        errorActionButton.isHidden = !errorViewModel.isRetryEnabled
        errorMessageLabel.text = errorViewModel.errorMessage
        errorImageView.image = errorViewModel.iconImage
        
    }
}
