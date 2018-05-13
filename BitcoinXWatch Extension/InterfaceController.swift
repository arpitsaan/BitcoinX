//
//  InterfaceController.swift
//  BitcoinXWatch Extension
//
//  Created by zom on 09/05/18.
//  Copyright © 2018 acyooman. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var pricesTable: WKInterfaceTable!
    
    var priceList:CoindeskData?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
       
        //use our group user defaults
//        NSUserDefaults *defaults = [[NSUserDefaults alloc]
//            initWithSuiteName:@"group.com.calvium.watch.dev.defaults"];
//
//        //get the greeting
//        NSString *greeting = [defaults objectForKey:@"greeting"];
//
//        //check if greeting isn't empty
//        if (greeting) {
//            NSLog(@"greeting = %@", greeting);
//        } else{
//            NSLog(@"no user defaults :(");
//        }
        
        let defaults = UserDefaults.init(suiteName: "group.com.acyooman.BitcoinX")
        self.priceList = defaults?.object(forKey: "priceData") as? CoindeskData

        guard ((priceList?.bpi.count) != nil) else {
            return
        }; pricesTable.setNumberOfRows((priceList?.bpi.count)!, withRowType: "PriceRow")
    }
}
