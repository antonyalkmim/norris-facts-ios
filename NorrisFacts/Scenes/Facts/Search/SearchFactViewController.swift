//
//  SearchFactViewController.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 11/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchFactViewController: UIViewController {

    var viewModel: SearchFactViewModelType?
    
    // MARK: - Outlets
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tagsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var disposeBag = DisposeBag()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    /// cell to calculate the tag size for flow layout `sizeForItemAt` method
    private var sizingCell: TagCell? = Bundle.main.loadNibNamed("TagCell", owner: self, options: nil)![0] as? TagCell
    
    /// Cancel bar button item to dismiss the screen
    private let cancelBarButtonItem = UIBarButtonItem(title: L10n.SearchFacts.cancel, style: .plain, target: nil, action: nil)
    
    /// Data source for `tagsCollectionView`
    let suggestionsDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(
        configureCell: { _, collectionView, indexPath, item -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(type: TagCell.self, indexPath: indexPath)
            cell.setup(title: item)
            return cell
        }
    )
    
    /// Datasource for past searches `tableView`
    let pastSearchesDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(
        configureCell: { _, tableView, indexPath, term -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(type: PastSearchCell.self, indexPath: indexPath)
            cell.termLabel.text = term.capitalized
            return cell
        }
    )
    
    /// Total cells width sum for current tagCells in tagsView
    ///
    /// It updates on `UICollectionViewDelegateFlowLayout.sizeForItemAt`
    /// and every time it updates, the viewController should update the `tagsCollectionView height
    private var totalItemsWitdh = BehaviorRelay<CGFloat>(value: 0)
    
    // MARK: - Initializers
    
    init(viewModel: SearchFactViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prevent to dissmiss when scroll down
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        setupViews()
        bindViewModel()
    }
    
    private func setupViews() {
        title = L10n.SearchFacts.title
        
        // navigation items
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // search bar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.returnKeyType = .search
        
        // past searches tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 34
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.registerCellWithNib(PastSearchCell.self)
        
        // suggestions collectionView
        let tagFlowLayout = TagFlowLayout()
        tagFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        tagFlowLayout.minimumLineSpacing = 4
        
        tagsCollectionView.collectionViewLayout = tagFlowLayout
        tagsCollectionView.delegate = self
        tagsCollectionView.registerCellWithNib(TagCell.self)
    }
    
    /// update tagsCollectionViewHeight for current num of items
    private func updateTagsCollectionViewHeight(totalItemsWidth: CGFloat) {
        let cellHeight = CGFloat(58)
        let numberOfLines = (totalItemsWidth / UIScreen.main.bounds.width).rounded(.up)
        tagsCollectionViewHeightConstraint.constant = numberOfLines * cellHeight
        view.layoutIfNeeded()
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        // Inputs
        
        rx.viewWillAppear
            .bind(to: viewModel.inputs.viewWillAppear)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.inputs.searchTerm)
            .disposed(by: disposeBag)
        
        cancelBarButtonItem.rx.tap
            .mapToVoid()
            .bind(to: viewModel.inputs.cancelSearch)
            .disposed(by: disposeBag)
        
        // Outputs
        
        searchController.searchBar.rx.textDidEndEditing
            .bind(to: viewModel.inputs.searchAction)
            .disposed(by: disposeBag)
        
        // past searches
        viewModel.outputs.pastSearches
            .bind(to: tableView.rx.items(dataSource: pastSearchesDataSource))
            .disposed(by: disposeBag)
        
        // suggestions tags
        viewModel.outputs.suggestions
            .asDriver(onErrorJustReturn: [])
            .drive(tagsCollectionView.rx.items(dataSource: suggestionsDataSource))
            .disposed(by: disposeBag)
        
        // height of tagsCollectionView increases dinamically
        totalItemsWitdh
            .asDriver(onErrorJustReturn: 120)
            .drive(onNext: { [weak self] totalItemsWidth in
                self?.updateTagsCollectionViewHeight(totalItemsWidth: totalItemsWidth)
            })
            .disposed(by: disposeBag)
        
        // select item
        let pastSearchSelected = tableView.rx.modelSelected(String.self).asObservable()
        let tagSelected = tagsCollectionView.rx.modelSelected(String.self).asObservable()
        
        let itemSelected = Observable
            .merge(pastSearchSelected, tagSelected).share()
        
        itemSelected
            .bind(to: viewModel.inputs.searchTerm)
            .disposed(by: disposeBag)
        itemSelected
            .mapToVoid()
            .bind(to: viewModel.inputs.searchAction)
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchFactViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = suggestionsDataSource.sectionModels[indexPath.section].items[indexPath.row]
        sizingCell?.setup(title: item)
        sizingCell?.layoutIfNeeded()
        let cellSize = sizingCell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? CGSize.zero
        totalItemsWitdh.accept(totalItemsWitdh.value + cellSize.width)
        return cellSize
    }
}
