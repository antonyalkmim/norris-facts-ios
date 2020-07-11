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

class SearchFactViewController: UIViewController {

    var viewModel: SearchFactViewModelType?
    
    var disposeBag = DisposeBag()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let cancelBarButtonItem = UIBarButtonItem(title: L10n.SearchFacts.cancel, style: .plain, target: nil, action: nil)
    
    init(viewModel: SearchFactViewModelType) {
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
        title = L10n.SearchFacts.title
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.searchController = searchController
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.returnKeyType = .search
        
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        // Inputs
        
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
        
    }

}
