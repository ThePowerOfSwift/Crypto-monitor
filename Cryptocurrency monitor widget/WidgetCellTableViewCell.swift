//
//  WidgetCellTableViewCell.swift
//  Coin
//
//  Created by Mialin Valentin on 01.08.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class WidgetCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coinImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var priceCoinLabel: UILabel!
    @IBOutlet weak var percentChangeView: UIView!
    @IBOutlet weak var percentChangeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        percentChangeView.layer.cornerRadius = 3
        percentChangeView.layer.masksToBounds = true
        
        coinNameLabel.minimumScaleFactor = 0.5
        coinNameLabel.adjustsFontSizeToFitWidth = true
        
        scaleFactor(label: priceCoinLabel)
        scaleFactor(label: percentChangeLabel)
        
    }
    
    func scaleFactor(label: UILabel) {
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
}
