//
//  InterfaceController.swift
//  AntiSleep WatchKit Extension
//
//  Created by suhseungju on 2023/01/21.
//

import WatchKit
import Foundation
import HealthKit
import CoreLocation

class InterfaceController: WKInterfaceController {
    var sleepCount : Int = 0
    
    let healthStore = HKHealthStore()
    
    // 심박수, 수면시간 권한 요청
    let typeToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
    let typeToShare = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
    var sleepData:[HKCategorySample] = [] // 수면 데이터 저장 배열
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var driveBtn: WKInterfaceButton!
    @IBOutlet weak var stopDrivingBtn: WKInterfaceButton!
    @IBOutlet weak var finishDriveBtn: WKInterfaceButton!
    
    @IBOutlet weak var countTextLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        configure()
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
    
    func configure() {
        if !HKHealthStore.isHealthDataAvailable() {
            //
        } else {
            requestAuthorization()
        }
    }
    
    func requestAuthorization() {
        self.healthStore.requestAuthorization(toShare: typeToShare, read: typeToRead) { (success, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                if success {
                    print("권한이 허락되었습니다.")
                } else {
                    print("권한이 아직 없습니다.")
                }
            }
        }
    }
    
    // 심장 박동수 가져오기
    // https://ios-dev-tech.tistory.com/12
    func getHeartRateData(completion: @escaping ([HKSample]) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) {
            (sample, result, error) in
            guard error == nil else {
                print("error")
                return
            }
            guard let resultData = result else {
                print("load result fail")
                return
            }
            DispatchQueue.main.async {
                completion(resultData)
            }
        }
        healthStore.execute(query)
    }
}
