//
//  AddTableViewCell.swift
//  Coin
//
//  Created by Mialin Valentin on 24.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class AddTableViewCell: UITableViewCell {

    @IBOutlet weak var cryptocurrencyImageView: UIImageView!
    @IBOutlet weak var cryptocurrencyNameLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scaleFactor(label: cryptocurrencyNameLabel)

    }

    func scaleFactor(label: UILabel) {
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
    }
}
