//
//  CoindeskAPI.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

protocol CoindeskAPIDelegate: class {
    
    func historialDataFetchedSuccessfully()
    
    func historialDataFetchFailedWithError(error: Error)
}

class CoindeskAPI: NSObject {
    private var currencyCode = "EUR"
    var latestData:CoindeskData?
    weak var delegate:CoindeskAPIDelegate?

    public func fetchLatestData() {
        
       URLSession.shared.dataTask(with: getAPIUrl()) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.delegate?.historialDataFetchFailedWithError(error: error!)
            }
            
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Coinbasedata object
                self.latestData = try JSONDecoder().decode(CoindeskData.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(self.latestData!)
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
    
    private func getAPIUrl() -> URL {
        let urlComps = NSURLComponents(string: "https://api.coindesk.com/v1/bpi/historical/close.json")!
        
        let queryItems = [NSURLQueryItem(name: "currency", value: self.currencyCode),
                          NSURLQueryItem(name: "start", value: self.getStartDateString()),
                          NSURLQueryItem(name: "end", value: self.getCurrentDateString())]
        
        urlComps.queryItems = queryItems as [URLQueryItem]
        
        guard let url = urlComps.url else { return URL.init(string: "")! }
        
        return url
    }
}
