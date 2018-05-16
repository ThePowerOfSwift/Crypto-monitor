//
//  Array.swift
//  Coin
//
//  Created by Mialin Valentin on 17.05.18.
//  Copyright © 2018 Mialin Valentyn. All rights reserved.
//

import Foundation

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
