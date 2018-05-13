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
            controller.priceLabel.setTextColor(UIColor.bxDarkTheme.orange)
        }
        
        //historial prices
        guard self.pricesAPI.historicalData != nil else {return}
        
        let keysArray = Array((self.pricesAPI.historicalData?.bpi.keys)!).sorted(by: >)
        
        var index = self.pricesAPI.isRealtimeDataAvailable() ? 1 : 0
        for dateString in keysArray {
            guard let controller = pricesTable.rowController(at: index) as? PriceRowController
                else {
                    statusLabel.setHidden(false)
                    self.statusLabel.setText("Something went wrong in displaying latest data.")
                    return
                }
            
            let rate:Double = (self.pricesAPI.historicalData?.bpi[dateString])!
            controller.dateLabel.setText(dateString)
            controller.priceLabel.setText(rate.formatAsEuro())
            controller.priceLabel.setTextColor(UIColor.white)
            index += 1;
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.pricesAPI.delegate = self
        self.pricesAPI.loadCachedData()
        self.pricesAPI.fetchHistoricalData()
        self.pricesAPI.fetchRealtimeData()
        statusLabel.setHidden(false)
        statusLabel.setText("Getting the latest exchange rate...")
    }
    
    func scheduleRealtimePriceUpdate() {
        //schedule next realtime price update
        Timer.scheduledTimer(timeInterval: CommonHelpers.getRealtimeUpdateInterval(),
                             target: self,
                             selector: #selector(self.makeRealtimePriceRequest),
                             userInfo: nil, repeats: false)
    }
    
    
    @objc func makeRealtimePriceRequest() {
        self.pricesAPI.fetchRealtimeData()
    }
}

extension InterfaceController: CoindeskAPIDelegate {
    func cachedDataLoadedSuccessfully() {
        self.tableRefresh()
    }
    
    func realtimeDataFetchedSuccessfully() {
        statusLabel.setHidden(true)
        self.scheduleRealtimePriceUpdate()
        tableRefresh()
    }
    
    func realtimeDataFetchFailedWithError(error: Error) {
        statusLabel.setHidden(false)
        self.statusLabel.setText(error.localizedDescription)
    }   
    
    func historialDataFetchedSuccessfully() {
        statusLabel.setHidden(true)
        tableRefresh()
    }
    
    func historialDataFetchFailedWithError(error: Error) {
        statusLabel.setHidden(false)
        self.statusLabel.setText(error.localizedDescription)
    }
}

