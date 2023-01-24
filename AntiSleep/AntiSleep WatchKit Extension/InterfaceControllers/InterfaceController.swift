//
//  InterfaceController.swift
//  AntiSleep WatchKit Extension
//
//  Created by suhseungju on 2023/01/21.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    var sleepCount : Int = 0

    @IBOutlet weak var driveBtn: WKInterfaceButton!
    @IBOutlet weak var stopDrivingBtn: WKInterfaceButton!
    @IBOutlet weak var finishDriveBtn: WKInterfaceButton!
    
    @IBOutlet weak var countTextLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func dBtnTapped() {
        self.pushController(withName: "drive", context: nil)
    }
    @IBAction func sdBtnTapped() {
        //driveBtn.setTitle("Driving")
        self.pushController(withName: "finishDrive", context: nil)
    }
    @IBAction func fdTapped() {
        //driveBtn.setTitle("Driving")
        self.pushController(withName: "startDrive", context: nil)
    }
    
    func setLabel() {
        self.countTextLabel.setText("졸음 운전 횟수 : \(sleepCount)")
    }
    
    var healthStore: HKHealthStore?
    
    
}

/*extension InterfaceController:HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        //
    }
    
    func workdoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
        }
    }
}*/

