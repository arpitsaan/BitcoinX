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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}

extension ViewController: CoindeskAPIDelegate {
    func getDataFromAPIService() {
        self.coindeskApiObject.delegate = self
        self.coindeskApiObject.fetchLatestData()
    }
    
    func historialDataFetchFailedWithError(error: Error) {
        self.tableView.reloadData()
    }
    
    func historialDataFetchedSuccessfully() {
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.coindeskApiObject.latestData != nil {
            return (self.coindeskApiObject.latestData?.bpi.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "BitcoinXRowIdentifier")
        if (cell == nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "BitcoinXRowIdentifier")
        }
        
        let keysArray = Array((self.coindeskApiObject.latestData?.bpi.keys)!).sorted(by: >)

        let date = keysArray[indexPath.row]
        let rate = self.coindeskApiObject.latestData?.bpi[keysArray[indexPath.row]]
        print(rate as Any)
        
        cell?.textLabel?.text = rate?.formatAsEuro()
        cell?.detailTextLabel?.text = date

        return cell!
    }
    
    
}

