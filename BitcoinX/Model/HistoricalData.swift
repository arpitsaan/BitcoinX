//
//  HistoricalData.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 10/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

struct HistoricalData: Codable {
    let bpi: [String: Double] //Bitcoin price index : Date -> Price
    let disclaimer: String
    let time: Time
}

struct Time: Codable {
    let updated, updatedISO: String
}
