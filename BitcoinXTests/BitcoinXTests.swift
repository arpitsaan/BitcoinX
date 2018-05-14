//
//  BitcoinXTests.swift
//  BitcoinXTests
//
//  Created by Arpit Agarwal on 08/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import XCTest
@testable import BitcoinX

class BitcoinXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //-------------------------------------
    // MARK: Test Data Caching and Helpers
    //-------------------------------------
    func testAppGroupString() {
        let groupString = CommonHelpers.getGroupUrlString()
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "App group string is not a nil path.")
        XCTAssertNotNil(groupString, "App group string is nil.")
        expectation.fulfill()
    }
    
    func testRefreshIntervalConfig() {
        let refreshInterval:TimeInterval = CommonHelpers.getRealtimeUpdateInterval()
        XCTAssert(refreshInterval > 20, "Expect refresh interval to be more than 20 seconds.")
    }
    
    func testRealtimeDataIsGettingSaved() {
        let mockTimeUpdate = TimeUpdated.init(updated: "mock123", updatedISO: "mock123", updateduk: "mock123")
        
        let mockBpi = Bpi.init(usd: Eur.init(code: "EUR", rate: "123.123", description: "desc", rateFloat: 123.123), eur:Eur.init(code: "EUR", rate: "123.123", description: "desc", rateFloat: 123.123))
        
        let mockRealtimeData = RealtimeData.init(time: mockTimeUpdate, disclaimer:"mockDisclaimer", bpi: mockBpi)
        CommonHelpers.saveRealtimeDataToDisk(data: mockRealtimeData)
        
        let data = CommonHelpers.getRealtimeDataFromDisk()
        
        let expectation = XCTestExpectation(description: "Data saved is not nil.")
        
        XCTAssertNotNil(data, "Realtime saved data is not nil.")
        
        expectation.fulfill()
    }
    
    func testHistoricalDataIsGettingSaved() {
        let mockTime = Time.init(updated: "mock123", updatedISO: "mock123")
        let mockHistoricalData = HistoricalData.init(bpi: ["1234":1234], disclaimer: "mockdisclaimer", time: mockTime)
        CommonHelpers.saveHistoricalDataToDisk(data: mockHistoricalData)
        
        let data = CommonHelpers.getRealtimeDataFromDisk()
        
        let expectation = XCTestExpectation(description: "Historical Data saved is not nil.")
        XCTAssertNotNil(data, "Historical saved data is not nil.")
        expectation.fulfill()
    }
    
    //--------------------------------
    // MARK: Test Realtime Prices API
    //--------------------------------
    func testRealtimeAPIEndpoint() {
        let coindeskApiObject = CoindeskAPI.init()
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download Realtime Bitcoin exchange data from Coindesk Url")
        
        // Create a URL for a web page to be downloaded.
        let url = coindeskApiObject.getRealtimeAPIUrl()
        
        // Create a background task to download the web page.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            // Make sure we downloaded some data.
            XCTAssertNotNil(data, "No data was downloaded from realtime prices API endpoint.")
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Start the download task.
        dataTask.resume()
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    //----------------------------------
    // MARK: Test Historical Prices API
    //----------------------------------
    func testHistoricalAPIEndpoint() {
        let coindeskApiObject = CoindeskAPI.init()
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download Historical Bitcoin exchange data from Coindesk Url")
        
        // Create a URL for a web page to be downloaded.
        let startDate = coindeskApiObject.getStartDateString()
        let endDate = coindeskApiObject.getCurrentDateString()
        let url = coindeskApiObject.getHistoricalAPIUrl(startDate: startDate, endDate: endDate)
        
        // Create a background task to download the web page.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            // Make sure we downloaded some data.
            XCTAssertNotNil(data, "No data was downloaded from historical prices API endpoint.")
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Start the download task.
        dataTask.resume()
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testDownloadedHistoricalDataParsed() {
        let coindeskApiObject = CoindeskAPI.init()

        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download Historical Bitcoin exchange data from Coindesk Url")
        
        // Create a URL for a web page to be downloaded.
        let startDate = coindeskApiObject.getStartDateString()
        let endDate = coindeskApiObject.getCurrentDateString()
        let url = coindeskApiObject.getHistoricalAPIUrl(startDate: startDate, endDate: endDate)
        var historicalData:HistoricalData?
        
        // Create a background task to download the web page.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            // Make sure we downloaded some data.
            XCTAssertNotNil(data, "No data was downloaded from historical prices API endpoint.")
            
            //historical data
            do {
                historicalData = try JSONDecoder().decode(HistoricalData.self, from: data!)
                XCTAssertNotNil(historicalData, "Historical data was not parsed successfully.");
            } catch let jsonError {
                print(jsonError)
            }
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Start the download task.
        dataTask.resume()
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }

}
