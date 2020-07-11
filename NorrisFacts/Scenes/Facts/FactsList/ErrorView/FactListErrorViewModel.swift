//
//  FactListErrorViewModel.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 07/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit

struct FactListErrorViewModel {
    
    private let factListError: FactsListViewModel.FactListError

    let errorMessage: String
    let isRetryEnabled: Bool
    let iconImage: UIImage
    
    init(factListError: FactsListViewModel.FactListError) {
        self.factListError = factListError
        
        switch factListError.error.code {
        case NetworkError.noInternetConnection.code:
            errorMessage = L10n.Errors.noInternetConnection
            iconImage = Asset.wifiError.image
            isRetryEnabled = false
        default:
            errorMessage = L10n.Errors.unknow
            iconImage = Asset.warning.image
            isRetryEnabled = true
        }
    }
}
