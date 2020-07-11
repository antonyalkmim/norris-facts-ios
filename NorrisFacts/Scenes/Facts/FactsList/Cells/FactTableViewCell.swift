//
//  FactTableViewCell.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 08/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import UIKit

class FactTableViewCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var factTextLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    let shortTextFontSize = CGFloat(23)
    let longTextFontSize = CGFloat(17)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    private func setupViews() {
        wrapperView.backgroundColor = UIColor.white
        wrapperView.layer.cornerRadius = 16
        categoryView.layer.cornerRadius = 16
    }
    
    func bindViewModel(_ viewModel: FactItemViewModelType) {
        categoryLabel?.text = viewModel.categoryTitle
        factTextLabel?.text = viewModel.factText
        
        let fontSize = viewModel.factText.count < 80 ? shortTextFontSize : longTextFontSize
        factTextLabel?.font = .systemFont(ofSize: fontSize, weight: .bold)
    }
}
