//
//  HeaderTableViewCell.swift
//  Coin
//
//  Created by Mialin Valentin on 27.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var priceCoinLabel: UILabel!
    @IBOutlet weak var percentChangeView: UIView!
    @IBOutlet weak var percentChangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        percentChangeView.layer.cornerRadius = 3
        percentChangeView.layer.masksToBounds = true
    }
}

class HeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var dataCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
