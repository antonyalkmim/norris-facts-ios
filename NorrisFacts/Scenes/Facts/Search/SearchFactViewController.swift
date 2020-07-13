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
    
    var disposeBag = DisposeBag()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    /// cell to calculate the tag size for flow layout `sizeForItemAt` method
    var sizingCell: TagCell? = Bundle.main.loadNibNamed("TagCell", owner: self, options: nil)![0] as? TagCell
    
    let cancelBarButtonItem = UIBarButtonItem(title: L10n.SearchFacts.cancel, style: .plain, target: nil, action: nil)
    
    let suggestionsDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, String>>(
        configureCell: { _, collectionView, indexPath, item -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(type: TagCell.self, indexPath: indexPath)
            cell.setup(title: item)
            return cell
        }
    )
    
    let pastSearchesDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(
        configureCell: { _, tableView, indexPath, item -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "kTableViewCell", for: indexPath)
            cell.textLabel?.text = item
            return cell
        }
    )
    
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
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "kTableViewCell")
        
        // suggestions collectionView
        let tagFlowLayout = TagFlowLayout()
        tagFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        tagFlowLayout.minimumLineSpacing = 4
        
        tagsCollectionView.collectionViewLayout = tagFlowLayout
        tagsCollectionView.delegate = self
        tagsCollectionView.registerCellWithNib(TagCell.self)
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
        
        let itemSelected = tagsCollectionView.rx.modelSelected(String.self).share()
        itemSelected
            .bind(to: viewModel.inputs.searchTerm)
            .disposed(by: disposeBag)
        itemSelected
            .mapToVoid()
            .bind(to: viewModel.inputs.searchAction)
            .disposed(by: disposeBag)
        
    }
    
}

extension SearchFactViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = suggestionsDataSource.sectionModels[indexPath.section].items[indexPath.row]
        sizingCell?.setup(title: item)
        sizingCell?.layoutIfNeeded()
        return sizingCell?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? CGSize.zero
    }
}
