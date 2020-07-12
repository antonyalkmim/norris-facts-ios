//
//  TagCell.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 12/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tagViewMaxWithConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelView.layer.cornerRadius = 16
        tagViewMaxWithConstraint.constant = UIScreen.main.bounds.width - 8 * 2 - 8 * 2
    }

    func setup(title: String) {
        textLabel.text = title.uppercased()
    }
    
}
