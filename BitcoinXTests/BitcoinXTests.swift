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
            XCTAssertNotNil(data, "No data was downloaded.")
            
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
        }
        
        // Start the download task.
        dataTask.resume()
        
        // Wait until the expectation is fulfilled, with a timeout of 15 seconds.
        wait(for: [expectation], timeout: 15.0)
    }
}
