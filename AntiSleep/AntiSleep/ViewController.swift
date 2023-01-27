//
//  ViewController.swift
//  AntiSleep
//
//  Created by suhseungju on 2023/01/21.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var driveBtn: UIButton!
    
    // 심박수, 수면시간 권한 요청
    let healthStore = HKHealthStore()
    var heartRateBPM = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authorizeHealthKit()
        setLabel()
    }
    
    func setLabel() {
        self.heartRateLabel.text = "HeartRate : \(self.heartRateBPM) BPM"
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
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
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
            print("StartDate : \(StartDate) - EndDate : \(EndDate)")
        }
        healthStore.execute(query)
    }
}
