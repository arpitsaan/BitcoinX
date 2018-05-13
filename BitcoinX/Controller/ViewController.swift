//
//  ViewController.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 08/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var coindeskApiObject = CoindeskAPI.init()
    var tableView:UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bitcoin EUR for last 15 days"
        
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        self.view.addSubview(tableView)
        tableView.fillSuperView()
        
        getDataFromAPIService()
    }
    
    func getDataFromAPIService() {
        self.coindeskApiObject.delegate = self
        self.coindeskApiObject.fetchRealtimeData()
        self.coindeskApiObject.fetchHistoricalData()
    }
    
    @objc func makeRealtimePriceRequest() {
        self.coindeskApiObject.fetchRealtimeData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scheduleRealtimePriceUpdate() {
        //schedule next realtime price update
        Timer.scheduledTimer(timeInterval: CommonHelpers.getRealtimeUpdateInterval(),
                             target: self,
                             selector: #selector(self.makeRealtimePriceRequest),
                             userInfo: nil, repeats: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

extension ViewController: CoindeskAPIDelegate {
    func realtimeDataFetchedSuccessfully() {
        self.tableView.reloadData()
        self.scheduleRealtimePriceUpdate()
    }
    
    func realtimeDataFetchFailedWithError(error: Error) {
        self.tableView.reloadData()
    }
    
    func historialDataFetchFailedWithError(error: Error) {
        self.tableView.reloadData()
    }
    
    func historialDataFetchedSuccessfully() {
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    
    enum tableSection:Int {
        case loader = 0
        case realtimePrice
        case historialPrices
        case sectionCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSection.sectionCount.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case tableSection.loader.rawValue:
            return 0
            
        case tableSection.realtimePrice.rawValue:
            return self.coindeskApiObject.isRealtimeDataAvailable() ? 1 : 0
            
        case tableSection.historialPrices.rawValue:
            return self.coindeskApiObject.getHistoricalDataRowsCount()
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            
        case tableSection.realtimePrice.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "BitcoinXRealtimeRowIdentifier")
            
            if (cell == nil) {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "BitcoinXRealtimeRowIdentifier")
            }
            let realtimeValue:Double = (self.coindeskApiObject.realtimeData?.bpi.eur.rateFloat)!
            cell?.textLabel?.text = realtimeValue.formatAsEuro()
            cell?.detailTextLabel?.text = self.coindeskApiObject.realtimeData?.time.updated
            
            return cell!
           
        case tableSection.historialPrices.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "BitcoinXRowIdentifier")
            
            if (cell == nil) {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "BitcoinXRowIdentifier")
            }
            
            let keysArray = Array((self.coindeskApiObject.historicalData?.bpi.keys)!).sorted(by: >)
            
            let date = keysArray[indexPath.row]
            let rate = self.coindeskApiObject.historicalData?.bpi[keysArray[indexPath.row]]
            print(rate as Any)
            
            cell?.textLabel?.text = rate?.formatAsEuro()
            cell?.detailTextLabel?.text = date
            
            return cell!
            
        default:
            return UITableViewCell.init()
        }
        
    }
    
    
}

