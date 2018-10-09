//
//  HeaderTableViewCell.swift
//  Coin
//
//  Created by Mialin Valentin on 27.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit
import CryptoCurrency
import AlamofireImage

class CoinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coinImageView: UIImageView!
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
    
    func settingCell(coin: Coin) {
        if let url = URL(string: coin.image) {
            coinImageView.af_setImage(withURL: url)
        }
        
        coinNameLabel.text = coin.name
        priceCoinLabel.text = coin.priceToString()
        
        
        percentChangeLabel.text = coin.priceChange24HToString()
        if let percent = coin.priceChange24H {
            if percent >= 0 {
                percentChangeView.backgroundColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
            }
            else{
                percentChangeView.backgroundColor = UIColor(red:1.00, green:0.23, blue:0.18, alpha:1.0)
            }
        }
        else{
            percentChangeView.backgroundColor = UIColor.orange
        }
    }
}

class HeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var dataCurrencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
