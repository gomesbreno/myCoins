//
//  CoinList.swift
//  MyCoins
//
//  Created by Breno Gomes on 19/11/18.
//  Copyright © 2018 Gomes Industries. All rights reserved.
//

import Foundation

struct CoinList: Codable {
    var USD: Coin
    var USDT: Coin
    var CAD: Coin
    var EUR: Coin
    var GBP: Coin
    var ARS: Coin
    var BTC: Coin
}

struct Coin: Codable {
    var code: String
    var name: String
    var bid: String
    var ask: String
    var timestamp: String
    
}
