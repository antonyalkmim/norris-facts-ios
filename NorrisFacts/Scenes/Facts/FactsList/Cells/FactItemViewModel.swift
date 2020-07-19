//
//  FactItemViewModel.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxDataSources

protocol FactItemViewModelType {
    var factText: String { get }
    var categoryTitle: String { get }
}

struct FactItemViewModel: FactItemViewModelType {

    let fact: NorrisFact
    
    let factText: String
    let categoryTitle: String
    
    init(fact: NorrisFact) {
        self.fact = fact
        self.factText = fact.text
        self.categoryTitle = (fact.categories.first?.title ?? L10n.FactsList.uncategorized).uppercased()
    }
}

extension FactItemViewModel: IdentifiableType {
    var identity: String {
        fact.id
    }
}

extension FactItemViewModel: Equatable { }
func == (lhs: FactItemViewModel, rhs: FactItemViewModel) -> Bool {
    return lhs.fact == rhs.fact
}
