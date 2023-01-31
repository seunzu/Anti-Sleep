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
    @IBOutlet weak var driveImage: WKInterfaceImage!
    @IBOutlet weak var driveBtn: WKInterfaceButton!
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    @IBOutlet weak var alarmLabel: WKInterfaceLabel!
    @IBOutlet weak var watchTimer: WKInterfaceTimer!
    @IBOutlet weak var heartRateBtn: WKInterfaceButton!
    @IBOutlet weak var weatherBtn: WKInterfaceButton!
    @IBOutlet weak var heartRateBpmBtn: WKInterfaceButton!
    
    let healthStore = HKHealthStore()
    var startedHeartRate : Bool = true
    //    var heartRateBPM : String!
    var heartRateBPM : Double = 0.0
    var calc : Double = 0.0
    var bpm : String!
    var bpm2 : Double = 0.0
    
    // 타이머 변수
    var startedTimer : Bool = false
//    var sleepTime = String()
    let queue = DispatchQueue.global()
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        authorizeHealthKit()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func dBtnTapped() {
        if !startedTimer {
            watchTimer.setDate(Date())
            driveBtn.setTitle("Driving")
            watchTimer.start()
            
        } else {
            driveBtn.setTitle("Drive")
            watchTimer.stop()
        }
        startedTimer = !startedTimer
    }
    
    @IBAction func hrbBtn() {
        print("heartRateManager")
        heartRateCountLabel.setText("HeartRate : \(heartRateBPM) BPM" )
        if bpm2 != heartRateBPM {
            bpm2 = heartRateBPM
            heartRateCalc()
        }
        getHeartRateData()
    }
    
    func heartRateManager() {
        if !startedHeartRate { // false
            print("heartRateManager error")
        } else {
            print("heartRateManager success")
            bpm = String(format: "%.2f", heartRateBPM)
            if bpm == nil ?? nil {
                print("bpm")
                heartRateCountLabel.setText("HeartRate : \(bpm) BPM" )
                if bpm2 != heartRateBPM {
                    bpm2 = heartRateBPM
                    heartRateCalc()
                }
                getHeartRateData()
            }
        }
    }
    
    func heartRateCalc() {
        calc = heartRateBPM - bpm2
        print("heartRatecalc : \(calc)")
        if (calc >= 15) {
            self.alarmLabel.setText("Drowsy Driving")
        } else {
            self.alarmLabel.setText("Happy Driving")
        }
    }
    
    // healthKit 권한 요청
    func authorizeHealthKit() {
        // 심박수, 수면시간 권한 요청
        let typeToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                              HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        let typeToShare = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                               HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        
        healthStore.requestAuthorization(toShare: typeToShare, read: typeToRead) { (success, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                if success {
                    print("권한이 허락되었습니다.")
                    self.getHeartRateData()
//                    self.getSleepData()
                } else {
                    print("권한이 아직 없습니다.")
                }
            }
        }
    }
    
    // 심장 박동수 가져오기
    // https://ios-dev-tech.tistory.com/12
    // https://www.youtube.com/watch?v=uzJXV_9IBoc
    func getHeartRateData() {
        // HKObjectType: HealthKitStore 대한 특정 유형의 데이터 식별 클래스
        // HKObjectType.quantityType: identifier에 대한 수량 유형 반환
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        // startDate: 1시간 전 ~ 현재 날짜 시간 정보
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())
        // HKQuery: HealthKit 안 모든 query class 위한 추상 클래스
        // HKQuery.predicateForSamples: 특정 시간 동안의 특정 데이터 반환
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) {
            (sample, result, error) in
            guard error == nil else {
                print("Something went wrong getting heartRate")
                self.startedHeartRate = !self.startedHeartRate
                return
            }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latesHr = data.quantity.doubleValue(for: unit)
            self.heartRateBPM = round(latesHr*100)/100
            print("HeartRate : \(self.heartRateBPM) BPM")
            self.heartRateManager()
            
            
            let dateFormator = DateFormatter()
            dateFormator.dateFormat = "dd/MM/yyyy hh:mm s"
            let StartDate = dateFormator.string(from: data.startDate)
            let EndDate = dateFormator.string(from: data.endDate)
            print("HeartRate StartDate \(StartDate) : HeartRate EndDate \(EndDate)")
        }
        healthStore.execute(query)
    }
    
//    // 수면 데이터 가져오기
//    // https://eysermans.com/post/creating-an-ios-14-widget-showing-health-data
//    func getSleepData() {
//        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
//            return
//        }
//        
//        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
//        let endDate = Date()
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//        
//        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) {
//            (query, result, error) in
//            guard error == nil else {
//                print("Something went wrong getting sleep analysis")
//                return
//            }
//            print("success")
//            var totalSeconds : Double = 0.0
//            
//            if let result = result {
//                for item in result {
//                    if let sample = item as? HKCategorySample {
//                        let timeInterval = sample.endDate.timeIntervalSince(sample.startDate)
//                        totalSeconds = totalSeconds + timeInterval
//                        print("SleepData StartDate \(sample.startDate) : SleepData EndDate: \(sample.endDate)")
//                    }
//                }
//            }
//            let result =
//                String(Int(totalSeconds / 3600)) + "h " +
//                String(Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
//                String(Int(totalSeconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))) + "s"
//            print("totalSleepTime : \(result)")
//            self.sleepTime = result
//        }
//        healthStore.execute(query)
//    }
}
