//
//  InterfaceController.swift
//  BitcoinXWatch Extension
//
//  Created by Arpit Agarwal on 09/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var pricesTable: WKInterfaceTable!
    
    @IBOutlet var statusLabel: WKInterfaceLabel!
    var priceList:CoindeskData?
    var pricesAPI = CoindeskAPI.init()
    
    func tableRefresh(){
        let rowCount = (self.pricesAPI.latestData?.bpi.count)!
        
        guard rowCount>0 else {
             return
        }
        
        pricesTable.setNumberOfRows(rowCount, withRowType: "BitcoinPriceRow")
        
        let keysArray = Array((self.pricesAPI.latestData?.bpi.keys)!).sorted(by: >)
        
        var index = 0
        for dateString in keysArray {
            guard let controller = pricesTable.rowController(at: index) as? PriceRowController else { continue }
            let rate:Double = (self.pricesAPI.latestData?.bpi[dateString])!
            controller.dateLabel.setText(dateString)
            controller.priceLabel.setText(rate.formatAsEuro())
            index += 1;
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.pricesAPI.delegate = self
        self.pricesAPI.fetchLatestData()
        statusLabel.setText("Loading...")
    }
}

extension InterfaceController: CoindeskAPIDelegate {
    func historialDataFetchedSuccessfully() {
        statusLabel.setHidden(true)
        tableRefresh()
    }
    
    func historialDataFetchFailedWithError(error: Error) {
        statusLabel.setHidden(false)
        self.statusLabel.setText("Something went wrong in fetching price index data.")
    }
    
    
}


//use group user defaults
//        NSUserDefaults *defaults = [[NSUserDefaults alloc]
//            initWithSuiteName:@"group.com.calvium.watch.dev.defaults"];
//
//        //get the greeting
//        NSString *greeting = [defaults objectForKey:@"greeting"];
//
//        //check if greeting isn't empty
//        if (greeting) {
//            NSLog(@"greeting = %@", greeting);
//        } else{
//            NSLog(@"no user defaults :(");
//        }
