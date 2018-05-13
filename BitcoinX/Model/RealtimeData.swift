//
//  RealtimeData.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit
import Foundation

struct RealtimeData: Codable {
    let time: TimeUpdated
    let disclaimer: String
    let bpi: Bpi
}

struct Bpi: Codable {
    let usd, eur: Eur
    
    enum CodingKeys: String, CodingKey {
        case usd = "USD"
        case eur = "EUR"
    }
}

struct Eur: Codable {
    let code, rate, description: String
    let rateFloat: Double
    
    enum CodingKeys: String, CodingKey {
        case code, rate, description
        case rateFloat = "rate_float"
    }
}

struct TimeUpdated: Codable {
    let updated, updatedISO, updateduk: String
}
