//
//  CurrentCurrencyTableViewCell.swift
//  Coin
//
//  Created by Mialin Valentin on 13.01.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import UIKit

class CurrentCurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
