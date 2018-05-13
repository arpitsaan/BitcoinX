//
//  Double+Additions.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import Foundation

extension Double {
    
    /// Formats the receiver as a currency string using the specified three digit currencyCode. Currency codes are based on the ISO 4217 standard.
    func formatAsEuro() -> String? {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "EU"
        currencyFormatter.currencySymbol = "€"
         currencyFormatter.maximumFractionDigits = floor(self) == self ? 0 : 2
        return currencyFormatter.string(from: NSNumber.init(value: self))
    }
}
