//
//  CoindeskAPI.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

//----------------------------
// MARK: Protocol Declaration
//----------------------------
protocol CoindeskAPIDelegate: class {
    func cachedDataLoadedSuccessfully()
    
    func realtimeDataFetchedSuccessfully()
    func realtimeDataFetchFailedWithError(error: Error)
    
    func historialDataFetchedSuccessfully()
    func historialDataFetchFailedWithError(error: Error)
}

//----------------------------
// MARK: Exposed API Methods
//----------------------------
class CoindeskAPI: NSObject {
    
    var historicalData:HistoricalData?
    var realtimeData:RealtimeData?
    weak var delegate:CoindeskAPIDelegate?
    private var currencyCode = "EUR"
    
    func loadCachedData() {
        self.historicalData = CommonHelpers.getHistoricalDataFromDisk()
        self.realtimeData = CommonHelpers.getRealtimeDataFromDisk()
        
        if self.historicalData != nil || self.realtimeData != nil {
            self.delegate?.cachedDataLoadedSuccessfully()
        }
    }
    
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
                
                DispatchQueue.main.async {
                    self.delegate?.realtimeDataFetchFailedWithError(error: error!)
                }
            }
            
            guard let data = data else { return }
            
            do {
                self.realtimeData = try JSONDecoder().decode(RealtimeData.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(self.realtimeData!)
                    CommonHelpers.saveRealtimeDataToDisk(data: self.realtimeData!)
                    self.delegate?.realtimeDataFetchedSuccessfully()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    public func fetchHistoricalData() {
        
        let startDate = getStartDateString()
        let endDate = getCurrentDateString()
        let historicalUrl = getHistoricalAPIUrl(startDate: startDate, endDate: endDate)
        
        URLSession.shared.dataTask(with: historicalUrl) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.historialDataFetchFailedWithError(error: error!)
                }
            }
            
            guard let data = data else { return }
            
            do {
                self.historicalData = try JSONDecoder().decode(HistoricalData.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(self.historicalData!)
                    CommonHelpers.saveHistoricalDataToDisk(data: self.historicalData!)
                    self.delegate?.historialDataFetchedSuccessfully()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}

//--------------------------
// MARK: API Helper Methods
//--------------------------
extension CoindeskAPI {
    
    func getStartDateString() -> String {
        //date for 2 weeks earlier
        let startDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        return startDateString
    }
    
    func getCurrentDateString() -> String {
        //today's date
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todaysDateString = dateFormatter.string(from: todaysDate)
        return todaysDateString
    }
    
    func getHistoricalAPIUrl(startDate: String, endDate: String ) -> URL {
        //generate historical price url
        let urlComps = NSURLComponents(string: "https://api.coindesk.com/v1/bpi/historical/close.json")!
        
        let queryItems = [NSURLQueryItem(name: "currency", value: self.currencyCode),
                          NSURLQueryItem(name: "start", value: startDate),
                          NSURLQueryItem(name: "end", value: endDate)]
        
        urlComps.queryItems = queryItems as [URLQueryItem]
        guard let url = urlComps.url else { return URL.init(string: "")! }
        return url
    }
    
    func getRealtimeAPIUrl() -> URL {
        //generate realtime price url
        var realtimeUrl = "https://api.coindesk.com/v1/bpi/currentprice/"
        realtimeUrl.append(self.currencyCode)
        realtimeUrl.append(".json")
        return URL.init(string: realtimeUrl)!
    }
}


//-----------
//FIXME: Upgrade to use the dependency injection design @arpit
/*
 Sample ->
 
     class HttpClient {
         typealias completeClosure = ( _ data: Data?, _ error: Error?)->Void
         private let session: URLSession
         init(session: URLSessionProtocol) {
         self.session = session
     }
     func get( url: URL, callback: @escaping completeClosure ) {
             let request = NSMutableURLRequest(url: url)
             request.httpMethod = "GET"
             let task = session.dataTask(with: request) { (data, response, error) in
             callback(data, error)
         }
            task.resume()
         }
     }
 */
