//
//  CoindeskAPI.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

protocol CoindeskAPIDelegate: class {
    func realtimeDataFetchedSuccessfully()
    func realtimeDataFetchFailedWithError(error: Error)
    
    func historialDataFetchedSuccessfully()
    func historialDataFetchFailedWithError(error: Error)
}

class CoindeskAPI: NSObject {
    private var currencyCode = "EUR"
    
    var historicalData:HistoricalData?
    var realtimeData:RealtimeData?
    weak var delegate:CoindeskAPIDelegate?
    
    func isRealtimeDataAvailable() -> Bool {
        guard realtimeData != nil else {
            return false
        }
        
        return realtimeData!.bpi.eur.rateFloat > 0.0
    }
    
    func getHistoricalDataRowsCount() -> Int {
        guard historicalData != nil else {
            return 0
        }
        
        return (historicalData?.bpi.count)!
    }

    public func fetchRealtimeData() {
        
        URLSession.shared.dataTask(with: getRealtimeAPIUrl()) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.delegate?.realtimeDataFetchFailedWithError(error: error!)
            }
            
            guard let data = data else { return }
            
            do {
                self.realtimeData = try JSONDecoder().decode(RealtimeData.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(self.realtimeData!)
                    self.delegate?.realtimeDataFetchedSuccessfully()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    public func fetchHistoricalData() {
        
       URLSession.shared.dataTask(with: getHistoricalAPIUrl()) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.delegate?.historialDataFetchFailedWithError(error: error!)
            }
            
            guard let data = data else { return }
        
            do {
                self.historicalData = try JSONDecoder().decode(HistoricalData.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(self.historicalData!)
                    self.delegate?.historialDataFetchedSuccessfully()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}

extension CoindeskAPI {
    
    private func getStartDateString() -> String {
        //date for 2 weeks ago
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        return startDateString
    }
    
    private func getCurrentDateString() -> String {
        //todays date
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todaysDateString = dateFormatter.string(from: todaysDate)
        return todaysDateString
    }
    
    private func getHistoricalAPIUrl() -> URL {
        let urlComps = NSURLComponents(string: "https://api.coindesk.com/v1/bpi/historical/close.json")!
        
        let queryItems = [NSURLQueryItem(name: "currency", value: self.currencyCode),
                          NSURLQueryItem(name: "start", value: self.getStartDateString()),
                          NSURLQueryItem(name: "end", value: self.getCurrentDateString())]
        
        urlComps.queryItems = queryItems as [URLQueryItem]
        
        guard let url = urlComps.url else { return URL.init(string: "")! }
        
        return url
    }
    
    private func getRealtimeAPIUrl() -> URL {
        var realtimeUrl = "https://api.coindesk.com/v1/bpi/currentprice/"
        realtimeUrl.append(self.currencyCode)
        realtimeUrl.append(".json")
        return URL.init(string: realtimeUrl)!
    }
}
