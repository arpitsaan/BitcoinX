//
//  CoindeskData.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 10/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

struct CoindeskData: Codable {
    let bpi: [String: Double]
    let disclaimer: String
    let time: Time
}

struct Time: Codable {
    let updated, updatedISO: String
}
