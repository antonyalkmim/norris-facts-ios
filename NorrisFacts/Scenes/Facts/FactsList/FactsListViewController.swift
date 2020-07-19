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

    var viewModel: FactsListViewModelType?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: AnimationView!
    
    // error view subviews
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorActionButton: UIButton!
    @IBOutlet weak var errorImageView: UIImageView!
    
    // empty state subviews
    @IBOutlet weak var searchFactsButton: UIButton!
    @IBOutlet weak var emptyView: UIStackView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    // current searchTerm label
    @IBOutlet weak var searchTermView: UIView!
    @IBOutlet weak var searchTermLabel: UILabel!
    @IBOutlet weak var clearSearchButton: UIButton!
    
    // constraints
    @IBOutlet weak var searchViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopSafeAreaConstraint: NSLayoutConstraint!
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: Asset.searchIcon.image, style: .plain, target: nil, action: nil)
        button.accessibilityIdentifier = "search_bar_button_item"
        return button
    }()
    
    /// Datasource for FactsTableView
    private lazy var factsDataSource = RxTableViewSectionedAnimatedDataSource<FactsSectionViewModel>(
        configureCell: { [weak self] _, tableView, indexPath, factViewModel -> UITableViewCell in
            
            guard let viewModel = self?.viewModel else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(type: FactTableViewCell.self, indexPath: indexPath)
            cell.bindViewModel(factViewModel)
            cell.shareFactButton.rx.tap
                .map { factViewModel }
                .bind(to: viewModel.inputs.shareItemAction)
                .disposed(by: cell.disposeBag)
            
            return cell
        }
    )
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    
    init(viewModel: FactsListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    // MARK: - Setup methods
    
    private func setupViews() {
        title = L10n.FactsList.title
        
        // navigationBar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        // retry button
        errorActionButton.setTitle(L10n.FactsList.retryButton, for: .normal)
        
        // current searchTerm view
        searchTermView.layer.cornerRadius = 16
        
        // loading animation
        loadingView.animation = Animation.named("loading-blue")
        loadingView.loopMode = .loop
        
        // tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.registerCellWithNib(FactTableViewCell.self)
    }
    
    // MARK: - Private methods
    
    private func showEmptyState(_ isEmptyState: Bool, isCurrentTermEmpty: Bool) {
        
        emptyView.isHidden = !isEmptyState
        errorView.isHidden = isEmptyState
        tableView.isHidden = isEmptyState
        
        if isCurrentTermEmpty {
            emptyImageView.image = Asset.searchBigIcon.image
            emptyMessageLabel.text = L10n.FactsList.emptyMessage
        } else {
            emptyImageView.image = Asset.warning.image
            emptyMessageLabel.text = L10n.FactsList.emptySearchMessage
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        loadingView.isHidden = !isLoading
        
        if isLoading {
            errorView.isHidden = true
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

// MARK: - Rx Bindings
extension FactsListViewController {
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        bindViewModelInputs(viewModel.inputs)
        bindViewModelOutputs(viewModel.outputs)
    }
    
    private func bindViewModelInputs(_ viewModelInputs: FactsListViewModelInput) {
        
        rx.viewDidAppear
            .bind(to: viewModelInputs.viewDidAppear)
            .disposed(by: disposeBag)
        
        errorActionButton.rx.tap
            .mapToVoid()
            .bind(to: viewModelInputs.retryErrorAction)
            .disposed(by: disposeBag)
        
        clearSearchButton.rx.tap
            .map { "" }
            .bind(to: viewModelInputs.setCurrentSearchTerm)
            .disposed(by: disposeBag)
        
        // show search form screen
        let searchButtonTap = searchFactsButton.rx.tap.mapToVoid()
        let searchBarButtonItemTap = searchBarButtonItem.rx.tap.mapToVoid()
        
        Observable.merge(searchButtonTap, searchBarButtonItemTap)
            .bind(to: viewModelInputs.searchButtonAction)
            .disposed(by: disposeBag)
        
    }
    
    private func bindViewModelOutputs(_ viewModelOutputs: FactsListViewModelOutput) {
        
        let currentSearchTerm = viewModelOutputs.currentSearchTerm.share()
        let factsViewModels = viewModelOutputs.factsViewModels.share()
        let errorViewModel = viewModelOutputs.errorViewModel.share()
        let isFactListEmpty = factsViewModels
            .map { $0.flatMap { $0.items } } // get all items in all sections
            .map { $0.isEmpty }
            .share()
        
        // loading state
        viewModelOutputs.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.showLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        // current search filter label
        currentSearchTerm
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] currentTerm in
                self?.bindCurrentSearchTerm(currentTerm)
            })
            .disposed(by: disposeBag)
        
        // bind facts SectionViewModel to tableView
        factsViewModels
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: factsDataSource))
            .disposed(by: disposeBag)
        
        // show empty state
        Observable
            .combineLatest(isFactListEmpty, currentSearchTerm.startWith(""))
            .asDriver(onErrorJustReturn: (true, ""))
            .drive(onNext: { [weak self] isEmpty, currentTerm in
                self?.showEmptyState(isEmpty, isCurrentTermEmpty: currentTerm.isEmpty)
            })
            .disposed(by: disposeBag)
        
        // show error view when empty list
        // show error toast when list is not empty
        let showErrorView = errorViewModel.withLatestFrom(isFactListEmpty)
        
        Observable
            .combineLatest(showErrorView, errorViewModel)
            .observeOn(MainScheduler.instance)
            .bind { [weak self] showErrorView, errorViewModel in
                if showErrorView {
                    self?.bindErrorViewModel(errorViewModel)
                } else {
                    self?.showToast(text: errorViewModel.errorMessage)
                }
            }.disposed(by: disposeBag)
        
    }
}
