//
//  CommonHelpers.swift
//  BitcoinX
//
//  Created by Arpit Agarwal on 13/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import Foundation

class CommonHelpers: NSObject {

    public static func getRealtimeUpdateInterval() -> TimeInterval {
        return 60
    }
    
    public static func getGroupUrlString() -> String {
        return "group.com.acyooman.BitcoinX"
    }
    
    //data caching helpers
    public static func getRealtimeDataFromDisk() -> RealtimeData? {
        if let retrievedRealtimeData = try? Disk.retrieve("realtimedata.json", from: .sharedContainer(appGroupName: CommonHelpers.getGroupUrlString()), as: RealtimeData.self) {
            print("Retrieved realtime data from disk!")
            return retrievedRealtimeData
        }
        return nil
    }
    
    public static func getHistoricalDataFromDisk() -> HistoricalData? {
        if let retrievedHistoricalData = try? Disk.retrieve("historicaldata.json", from: .sharedContainer(appGroupName: CommonHelpers.getGroupUrlString()), as: HistoricalData.self) {
            print("Retrieved historical data from disk!")
            return retrievedHistoricalData
        }
        return nil
    }
    
    public static func saveRealtimeDataToDisk(data: RealtimeData) {
        do {
            try Disk.save(data, to: .sharedContainer(appGroupName: CommonHelpers.getGroupUrlString()), as: "realtimedata.json")
        }
        catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    
    public static func saveHistoricalDataToDisk(data: HistoricalData) {
        do {
            try Disk.save(data, to: .sharedContainer(appGroupName: CommonHelpers.getGroupUrlString()), as: "historicaldata.json")
        }
        catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }    }
    
}
