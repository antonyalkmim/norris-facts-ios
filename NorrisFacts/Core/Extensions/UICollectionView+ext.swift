//
//  UICollectionView+ext.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 12/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func registerCellWithNib(_ cellClass: UICollectionViewCell.Type) {
        let nib = UINib(nibName: String(describing: cellClass.self), bundle: nil)
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellClass.self))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T ?? T()
    }
}
