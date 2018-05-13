//
//  PriceRowController.swift
//  BitcoinXWatch Extension
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import WatchKit

class PriceRowController: NSObject {
    @IBOutlet var bitcoinLogoImage: WKInterfaceImage!
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var dateLabel: WKInterfaceLabel!
    @IBOutlet var priceLabel: WKInterfaceLabel!
}
