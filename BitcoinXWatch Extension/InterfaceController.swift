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
    var priceList:HistoricalData?
    var pricesAPI = CoindeskAPI.init()
    
    func tableRefresh(){
        var rowCount = self.pricesAPI.getHistoricalDataRowsCount()
        rowCount += self.pricesAPI.isRealtimeDataAvailable() ? 1 : 0

        guard rowCount>0 else {
             return
        }
        
        pricesTable.setNumberOfRows(rowCount, withRowType: "BitcoinPriceRow")
        
        //realtime price row
        if self.pricesAPI.isRealtimeDataAvailable() {
            guard let controller = pricesTable.rowController(at: 0) as? PriceRowController else { return }
            
            let rate:Double = (self.pricesAPI.realtimeData?.bpi.eur.rateFloat)!
            controller.dateLabel.setText(self.pricesAPI.realtimeData?.time.updated)
            controller.priceLabel.setText(rate.formatAsEuro())
        }
        
        //historial prices
        guard self.pricesAPI.historicalData != nil else {return}
        
        let keysArray = Array((self.pricesAPI.historicalData?.bpi.keys)!).sorted(by: >)
        
        var index = self.pricesAPI.isRealtimeDataAvailable() ? 1 : 0
        for dateString in keysArray {
            guard let controller = pricesTable.rowController(at: index) as? PriceRowController
                else {
                    statusLabel.setHidden(false)
                    self.statusLabel.setText("Something went wrong in displaying realtime price index.")
                    return
                }
            
            let rate:Double = (self.pricesAPI.historicalData?.bpi[dateString])!
            controller.dateLabel.setText(dateString)
            controller.priceLabel.setText(rate.formatAsEuro())
            index += 1;
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.pricesAPI.delegate = self
        self.pricesAPI.fetchHistoricalData()
        self.pricesAPI.fetchRealtimeData()
        statusLabel.setText("Fetching data...")
    }
}

extension InterfaceController: CoindeskAPIDelegate {
    func realtimeDataFetchedSuccessfully() {
        statusLabel.setHidden(true)
        tableRefresh()
    }
    
    func realtimeDataFetchFailedWithError(error: Error) {
        statusLabel.setHidden(false)
        self.statusLabel.setText("Something went wrong in fetching realtime price data.")
    }   
    
    func historialDataFetchedSuccessfully() {
        statusLabel.setHidden(true)
        tableRefresh()
    }
    
    func historialDataFetchFailedWithError(error: Error) {
        statusLabel.setHidden(false)
        self.statusLabel.setText("Something went wrong in fetching historical prices.")
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
