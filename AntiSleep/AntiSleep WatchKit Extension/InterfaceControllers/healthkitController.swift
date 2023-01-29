//
//  healthkitController.swift
//  AntiSleep WatchKit Extension
//
//  Created by suhseungju on 2023/01/25.
//

import WatchKit
import Foundation
import HealthKit

class healthkitController: WKInterfaceController {
    var healthStore: HKHealthStore?
    
    if HKHealthStore.isHealthDataAvailable() {
        healthStore = HKHealthStore()
    }
    else {
    }
    
    
}
