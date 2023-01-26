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
    @IBOutlet weak var heartImage: WKInterfaceImage!
    @IBOutlet weak var driveBtn: WKInterfaceButton!
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    @IBOutlet weak var sleepCountLabel: WKInterfaceLabel!
    
    var sleepCount : Int = 0
    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    var value : Int = 0

    // 심박수, 수면시간 권한 요청
    let typeToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
    let typeToShare = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
    var sleepData:[HKCategorySample] = [] // 수면 데이터 저장 배열

    var locationManager = CLLocationManager()

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
        //self.pushController(withName: "drive", context: nil)
        driveBtn.setTitle("Driving")
    }

    func setLabel() {
        self.sleepCountLabel.setText("졸음 운전 횟수 : \(sleepCount)")
        self.heartRateCountLabel.setText("\(value)")
    }

    func configure() {
        if !HKHealthStore.isHealthDataAvailable() {
            //
        } else {
            requestAuthorization()
        }
    }

    // healthKit 권한 요청
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
