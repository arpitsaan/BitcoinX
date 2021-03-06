//
//  ViewController.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 08/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import UIKit

//----------------------
// MARK:  View Setup
//----------------------
class ViewController: UIViewController {

    var coindeskApiObject = CoindeskAPI.init()
    var tableView:UITableView = UITableView()
    var showError = false
    var errorMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        setupTableView()
        getData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.black
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.view.addSubview(tableView)
        tableView.fillSuperView()
    }

    func resetNavigationTitle() {
        navigationItem.title = "BitcoinX"
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//------------------------
// MARK: View Data Logics
//------------------------
extension ViewController {
    func getData() {
        self.coindeskApiObject.delegate = self
        self.coindeskApiObject.loadCachedData()
        self.coindeskApiObject.fetchRealtimeData()
        self.coindeskApiObject.fetchHistoricalData()
        navigationItem.title = "Updating..."
    }
    
    func scheduleRealtimePriceUpdate() {
        //schedule next realtime price update
        Timer.scheduledTimer(timeInterval: CommonHelpers.getRealtimeUpdateInterval(),
                             target: self,
                             selector: #selector(self.makeRealtimePriceRequest),
                             userInfo: nil, repeats: false)
    }
    
    @objc func makeRealtimePriceRequest() {
        self.coindeskApiObject.fetchRealtimeData()
        navigationItem.title = "Updating..."
    }
}

//-----------------------
// MARK: API Delegates
//-----------------------
extension ViewController: CoindeskAPIDelegate {
    func cachedDataLoadedSuccessfully() {
        self.tableView.reloadData()
    }
    
    func realtimeDataFetchedSuccessfully() {
        showError = false
        self.tableView.reloadData()
        self.scheduleRealtimePriceUpdate()
        self.resetNavigationTitle()
    }
    
    func realtimeDataFetchFailedWithError(error: Error) {
        showError = true
        errorMessage = error.localizedDescription
        self.tableView.reloadData()
        self.resetNavigationTitle()
    }
    
    func historialDataFetchedSuccessfully() {
        showError = false
        self.resetNavigationTitle()
        self.tableView.reloadData()
    }
    
    func historialDataFetchFailedWithError(error: Error) {
        showError = true
        errorMessage = error.localizedDescription
        self.resetNavigationTitle()
        self.tableView.reloadData()
    }
}

//--------------------------
// MARK: Table Data Source
//--------------------------
extension ViewController: UITableViewDataSource {
    
    enum tableSection:Int {
        case errorMessage = 0
        case realtimePrice
        case historialPrices
        case sectionCount
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSection.sectionCount.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case tableSection.errorMessage.rawValue:
            if showError {
                return 1
            }
            
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
        
            //--------------------
            // error message cell
            //--------------------
        case tableSection.errorMessage.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "BitcoinXErrorRowIdentifier")
            
            if (cell == nil) {
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "BitcoinXErrorRowIdentifier")
            }
            cell?.textLabel?.text = self.errorMessage
            cell?.textLabel?.textColor =  UIColor.white
            cell?.backgroundColor = UIColor.bxDarkTheme.darkBg
            
            return cell!
            
            //--------------------
            // realtime price cell
            //--------------------
        case tableSection.realtimePrice.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "BitcoinXRealtimeRowIdentifier")
            
            if (cell == nil) {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "BitcoinXRealtimeRowIdentifier")
            }
            let realtimeValue:Double = (self.coindeskApiObject.realtimeData?.bpi.eur.rateFloat)!
            cell?.detailTextLabel?.text = realtimeValue.formatAsEuro()
            cell?.textLabel?.text = self.coindeskApiObject.realtimeData?.time.updated
            
            cell?.detailTextLabel?.textColor = UIColor.bxDarkTheme.orange
            cell?.textLabel?.textColor =  UIColor.bxDarkTheme.gray
            cell?.backgroundColor = UIColor.black
            
            return cell!
           
            //-----------------------
            // historical price cells
            //-----------------------
        case tableSection.historialPrices.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "BitcoinXRowIdentifier")
            
            if (cell == nil) {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "BitcoinXRowIdentifier")
            }
            
            let keysArray = Array((self.coindeskApiObject.historicalData?.bpi.keys)!).sorted(by: >)
            
            let date = keysArray[indexPath.row]
            let rate = self.coindeskApiObject.historicalData?.bpi[keysArray[indexPath.row]]
            print(rate as Any)
            
            cell?.detailTextLabel?.text = rate?.formatAsEuro()
            cell?.textLabel?.text = date
            
            cell?.detailTextLabel?.textColor = UIColor.white
            cell?.textLabel?.textColor = UIColor.bxDarkTheme.gray
            cell?.backgroundColor = UIColor.black
            
            return cell!
            
        default:
            return UITableViewCell.init()
        }
    }
}

