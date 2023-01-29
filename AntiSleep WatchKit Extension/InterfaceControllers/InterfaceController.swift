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

/*import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: Text("Hello World")){
                Text("Hello :)")
            }
            .navigationBarTitle("Navigation")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}*/

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var heartImage: WKInterfaceImage!
    @IBOutlet weak var driveBtn: WKInterfaceButton!
    @IBOutlet weak var heartRateCountLabel: WKInterfaceLabel!
    @IBOutlet weak var sleepCountLabel: WKInterfaceLabel!
    
    //BDalarm: Alam that will be shown Before Driving
    @IBOutlet weak var BDalarm: WKInterfaceTextField!
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    
    

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
    

    public enum HKCategoryValueSleepAnalysis : Int {
        case inBed = 0
        case Asleep = 1
    }
    //sleep data 가져오기
    func retrieveSleepData() {
        
        let start = makeStringToDate(str: "2023-01-27")
        let end = Date()
        
        let sample = HKCategorySample(
            type: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) ?? <#default value#>,
            value: HKCategoryValueSleepAnalysis.Asleep.rawValue,
            start: start,
            end: end
        )
        
        let predicate = HKQuery.predicateForSamples(withStart:start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        
        let sleepQuery = HKSampleQuery(sampleType: HKCategoryType(.sleepAnalysis), predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { [self] (query, sleepResult, error) -> Void in
            
            if error != nil {
                return
            }
            
            if let result = sleepResult{
                for item in result {
                    if let sample = item as? HKCategorySample {
                        if sample.value == 1 {
                            let StartDate = sample.startDate
                            let endDate = sample.endDate
                            print()
                            let sleepTimeForOneDay = sample.endDate.timeIntervalSince(sample.startDate)
                        }
                    }
                }
            }
            
            healthStore.execute(sleepQuery)
        }
    }
    
    /*private func loadTableData() {
        tableView.setNumberOfRows(sleepData.count, withRowType: "RowController")
        for (index, rowModel) in sleepData.enumerated() {
            print(rowModel)
            if let rowController = tableView.rowController(at: index) as? RowTableController {
                rowController.rowLabel.setText(rowModel)
            }
            
        }
        
    }*/
    func saveSleepData() {
            let start = makeStringToDateWithTime(str: "2023-01-27 10:00")
            //let end = makeStringToDateWithTime(str: "2021-07-10 11:00")
            
            let object = HKCategorySample(type: HKCategoryType(.sleepAnalysis), value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: start,end: Date())
            healthStore.save(object, withCompletion: { (success, error) -> Void in
                if error != nil {
                    return
                }
                if success {
                    print("수면 데이터 저장 완료!")
                    self.retrieveSleepData()
                } else {
                    print("수면 데이터 저장 실패...")
                }
            })
        }
    
    func makeStringToDate(str:String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")

            return dateFormatter.date(from: str)!
        }
    
    func makeStringToDateWithTime(str:String) -> Date {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
           dateFormatter.locale = Locale(identifier: "ko_KR")
           dateFormatter.timeZone = TimeZone(abbreviation: "KST")

           return dateFormatter.date(from: str)!
       }
       
       func dateToString(date:Date) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"

          return dateFormatter.string(from: date)
       }
       
       func dateToStringOnlyTime(date:Date) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "HH:mm"

          return dateFormatter.string(from: date)
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

/*extension InterfaceController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sleepData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sleep = sleepData[indexPath.row]
        let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let date = dateToString(date: sleep.startDate)
        let start = dateToStringOnlyTime(date: sleep.startDate)
        let end = dateToStringOnlyTime(date: sleep.endDate)
      
        cell.textLabel?.text = "\(date): \(start)부터 ~ \(end)까지 잤네요."
        
        return cell
    }
}
 */


