//
//  ViewController.swift
//  AntiSleep
//
//  Created by suhseungju on 2023/01/21.
//

//import UIKit
//import HealthKit
//
//class ViewController: UIViewController {
//
//    @IBOutlet weak var tableView: UIStackView!
//    @IBOutlet weak var heartRateLabel: UILabel!
//
//    // 심박수, 수면시간 권한 요청
//    let healthStore = HKHealthStore()
//    var query: HKStatisticsCollectionQuery?
//    var dateValues: [HKStatistics] = []
//
//    let typeToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
//                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
//    let typeToShare = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
//                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
//
//    var sleepData:[HKCategorySample] = [] // 수면 데이터 저장 배열
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        self.tableView.dataSource = self
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        healthStore.requestAuthorization(toShare: typeToShare, read: typeToRead) { (success, error) in
//            if error != nil {
//                print(error.debugDescription)
//            } else {
//                if success {
//                    print("권한이 허락되었습니다.")
//                } else {
//                    print("권한이 아직 없습니다.")
//                }
//            }
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // 데이터 필요X -> 쿼리 중지
//        self.healthStore.stop(query!)
//    }
//
//    func calcDailyHeartRateCountForPastWeek() {
//        let monday = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//        let daily = DateComponents(day: 1)
//        let exactlySevenDaysAgo = Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
//        let oneWeekAgo = HKQuery.predicateForSamples(withStart: exactlySevenDaysAgo, end: nil, options: .strictStartDate)
//
//        self.query = HKStatisticsCollectionQuery(quantityType: stepType,
//                                                         quantitySamplePredicate: oneWeekAgo,
//                                                         options: .cumulativeSum,
//                                                         anchorDate: monday,
//                                                         intervalComponents: daily)
//
//        self.query?.initialResultsHandler = { _, statisticsCollection, _ in
//            if let statisticsCollection = statisticsCollection {
//                self.updateUIFromStatistics(statisticsCollection)
//            }
//        }
//
//        self.query?.statisticsUpdateHandler = { _, _, statisticsCollection, _ in
//            if let statisticsCollection = statisticsCollection {
//                self.updateUIFromStatistics(statisticsCollection)
//            }
//        }
//        self.healthStore.execute(query!)
//    }
//
//    func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
//        DispatchQueue.main.async {
//            self.dateValues = []
//
//            let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
//            let endDate = Date()
//
//            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { [weak self] (statistics, _) in
//                    self?.dateValues.append(statistics)
//                }
//            self.tableView.reloadInputViews()
//        }
//    }
//}
//
//extension ViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        self.dateValues.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
//            cell.configure(with: dateValues[indexPath.row])
//            return cell
//    }
//}
