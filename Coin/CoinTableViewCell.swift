//
//  CoinTableViewCell.swift
//  Coin
//
//  Created by Mialin Valentin on 11.07.17.
//  Copyright © 2017 Mialin Valentyn. All rights reserved.
//

import UIKit

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
        
        percentChangeLabel.numberOfLines = 1
        percentChangeLabel.minimumScaleFactor = 0.5
        percentChangeLabel.adjustsFontSizeToFitWidth = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
