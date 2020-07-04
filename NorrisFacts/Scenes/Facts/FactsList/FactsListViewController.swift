//
//  FactsListViewController.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit

class FactsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let factsService = NorrisFactsService()
        factsService.searchFacts(term: "asdasd")
        
    }

}
