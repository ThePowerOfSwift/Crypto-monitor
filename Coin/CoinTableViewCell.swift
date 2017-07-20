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
    @IBOutlet weak var percentChange_24h_View: UIView!
    @IBOutlet weak var percent_change_24h_Label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        percentChange_24h_View.layer.cornerRadius = 3
        percentChange_24h_View.layer.masksToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
