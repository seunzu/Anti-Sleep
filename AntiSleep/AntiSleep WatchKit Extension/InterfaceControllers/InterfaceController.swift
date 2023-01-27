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
    @IBOutlet weak var heartImage: WKInterfaceImage!
    @IBOutlet weak var driveBtn: WKInterfaceButton!
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    @IBOutlet weak var sleepCountLabel: WKInterfaceLabel!
    @IBOutlet weak var watchTimer: WKInterfaceTimer!
    @IBOutlet weak var heartRateBtn: WKInterfaceButton!
    @IBOutlet weak var weatherBtn: WKInterfaceButton!
    
    let healthStore = HKHealthStore()
    var heartRateBPM = String()
    // 타이머 변수
    var doneTimer:Timer = Timer()
    var startedTimer:Bool = false

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        authorizeHealthKit()
//        setLabel()
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
    
    func setLabel() {
        self.heartRateCountLabel.setText("HeartRate : \(self.heartRateBPM) BPM")
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
                return
            }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latesHr = data.quantity.doubleValue(for: unit)
            self.heartRateBPM = String(format: "%.2f", latesHr)
            print("HeartRate : \(self.heartRateBPM) BPM")

            let dateFormator = DateFormatter()
            dateFormator.dateFormat = "dd/MM/yyyy hh:mm s"
            let StartDate = dateFormator.string(from: data.startDate)
            let EndDate = dateFormator.string(from: data.endDate)
            print("StartDate \(StartDate) : EndDate \(EndDate)")
        }
        healthStore.execute(query)
    }
}
