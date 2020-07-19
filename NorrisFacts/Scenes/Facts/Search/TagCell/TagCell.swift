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
    @IBOutlet weak var tagViewMaxWidthConstraint: NSLayoutConstraint!
    
    private let horizontalMargin = CGFloat(16)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelView.layer.cornerRadius = 16
        tagViewMaxWidthConstraint.constant = UIScreen.main.bounds.width - horizontalMargin - horizontalMargin
    }

    func setup(title: String) {
        textLabel.text = title.uppercased()
    }
    
}
