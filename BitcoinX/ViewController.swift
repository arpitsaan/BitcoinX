//
//  ViewController.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 08/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableView:UITableView = UITableView()
    var coinbaseData:CoinbaseData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Rest API"
        
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
        tableView.fillSuperView()
        
     
        self.getCoinbaseDataFromServer()
    }

    func getCoinbaseDataFromServer() {
        
        let queryItems = [NSURLQueryItem(name: "currency", value: "EUR"), NSURLQueryItem(name: "id", value: "3232")]
        let urlComps = NSURLComponents(string: "https://api.coindesk.com/v1/bpi/historical/close.json")!
        urlComps.queryItems = queryItems as [URLQueryItem]
        guard let url = urlComps.url else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            //Implement JSON decoding and parsing
            do {
                //Decode retrived data with JSONDecoder and assing type of Coinbasedata object
                let bitcoinData = try JSONDecoder().decode(CoinbaseData.self, from: data)
                
                //Get back to the main queue
                DispatchQueue.main.async {
                    print(bitcoinData)
                    self.coinbaseData = bitcoinData
                    
                    self.tableView.reloadData()
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.coinbaseData != nil {
            return (self.coinbaseData?.bpi.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "randomId")
        if (cell == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "randomId")
        }
        
        let keysArray = Array((self.coinbaseData?.bpi.keys)!) // for Dictionary

        let date = keysArray[indexPath.row]
        let rate = self.coinbaseData?.bpi[keysArray[indexPath.row]]
        print(rate as Any)
        
        cell?.textLabel?.text = String(format:"%f", rate!)
        cell?.detailTextLabel?.text = date

        return cell!
    }
    
    
}

extension ViewController {
    
    func getLastWeeksDateString() -> String {
        let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastWeekDateString = dateFormatter.string(from: lastWeekDate)
        return lastWeekDateString
    }
    
    func getTodaysDateString() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todaysDateString = dateFormatter.string(from: todaysDate)
        return todaysDateString
    }
}

extension ViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

