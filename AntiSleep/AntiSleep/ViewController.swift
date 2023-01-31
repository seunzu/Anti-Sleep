//
//  ViewController.swift
//  AntiSleep
//
//  Created by suhseungju on 2023/01/21.
//

import UIKit
import HealthKit
import Alamofire
import AlamofireImage
import CoreLocation
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var heartRateImage: UIImageView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var heartRateManageLabel: UILabel!
    @IBOutlet weak var driveBtn: UIButton!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var sleepImage: UIImageView!
    @IBOutlet weak var sleepDataLbael: UILabel!
    @IBOutlet weak var sleepDataManageLabel: UILabel!
    
    // 심박수, 수면시간 권한 요청
    let healthStore = HKHealthStore()
    var startedHeartRate : Bool = true
    //    var heartRateBPM : String!
    var heartRateBPM : Double = 0.0
    var calc : Double = 0.0
    var bpm : String!
    var bpm2 : Double = 0.0
    var startedSleepData : Bool = true
    var sleepTime = String()
    var sleepCalc : Double = 0.0

    
    //날씨
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    //날씨 변수
    var currentData:CurrentWeaterData! //전체 데이터 저장
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authorizeHealthKit()
        
        driveBtn.setBackgroundImage(UIImage(named: "drive"), for: .normal)
        driveBtn.layoutIfNeeded()
        driveBtn.subviews.first?.contentMode = .scaleAspectFit
        locationManager.delegate = self
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
                    self.getSleepData()
                } else {
                    print("권한이 아직 없습니다.")
                }
            }
        }
    }
    
    @IBAction func dBtnTapped() {
        // heartRateManager
        print("heartRateManager")
        heartRateLabel.text = "HeartRate : \(heartRateBPM) BPM"
        if bpm2 != heartRateBPM {
            bpm2 = heartRateBPM
            heartRateCalc()
        }
        getHeartRateData()
        
        // sleepDataManager
        print("sleepDataManager")
        sleepDataLbael.text = "\(sleepTime)"
        sleepDataCalc()
    }
    
    // heartRate
    func heartRateManager() {
        if !startedHeartRate { // false
            print("heartRateManager error")
        } else {
            print("heartRateManager success")
            bpm = String(format: "%.2f", heartRateBPM)
            if bpm == nil ?? nil {
                print("bpm")
                heartRateLabel.text = "HeartRate : \(bpm) BPM"
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
            self.heartRateManageLabel.text = "Drowsy Driving"
        } else {
            self.heartRateManageLabel.text = "Happy Driving"
        }
    }
    
    // sleepData
    func sleepDataManager() {
        if !startedSleepData { // false
            print("sleepDataManager error")
        } else {
            print("sleepDataManager success")
            sleepDataLbael.text = "\(sleepTime)"
            sleepDataCalc()
        }
    }
    
    func sleepDataCalc() {
        print("sleepDataCalc : \(sleepTime)")
        if sleepCalc <= 18000 { // 5시간
            self.sleepDataManageLabel.text = "졸음 운전 주의하세요."
        } else {
            self.sleepDataManageLabel.text = "안전 운전하세요."
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
            self.heartRateBPM = round(latesHr*100)/100
            print("HeartRate : \(self.heartRateBPM) BPM")
            self.heartRateManager()

            let dateFormator = DateFormatter()
            dateFormator.dateFormat = "dd/MM/yyyy hh:mm s"
            let StartDate = dateFormator.string(from: data.startDate)
            let EndDate = dateFormator.string(from: data.endDate)
            print("StartDate : \(StartDate) - EndDate : \(EndDate)")
        }
        healthStore.execute(query)
    }
    
    // 수면 데이터 가져오기
    // https://eysermans.com/post/creating-an-ios-14-widget-showing-health-data
    func getSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) {
            (query, result, error) in
            guard error == nil else {
                print("Something went wrong getting sleep analysis")
                self.startedSleepData = !self.startedSleepData
                return
            }
            print("success")
            var totalSeconds : Double = 0.0
            
            if let result = result {
                for item in result {
                    if let sample = item as? HKCategorySample {
                        let timeInterval = sample.endDate.timeIntervalSince(sample.startDate)
                        totalSeconds = totalSeconds + timeInterval
                        print("SleepData StartDate \(sample.startDate) : SleepData EndDate: \(sample.endDate)")
                    }
                }
            }
            let result =
                String(Int(totalSeconds / 3600)) + "h " +
                String(Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                String(Int(totalSeconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))) + "s"
            print("totalSleepTime : \(result)")
            self.sleepTime = result
            self.calc = totalSeconds
            self.sleepDataManager()
        }
        healthStore.execute(query)
    }
    
    //알람 권한 구현
    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispatchNotification()
            case .denied:
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in if didAllow {
                    self.dispatchNotification()
                }
            }
            default:
                return
        }
      }
    }
    //알람 내용 구현
    func dispatchNotification() {
        let title = "AntiSleep"
        let body = "졸음운전이 의심됩니다"
        let hour = 16
        let minute = 43
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calender = Calendar.current
        var dateComponents = DateComponents(calendar: calender, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [UUID().uuidString])
        notificationCenter.add(request)
        
        
    }
    
    func getData(_ location:CLLocationCoordinate2D) {
        
        
        let headers: HTTPHeaders=[
            //"appid": "51518b2be4cd74362f31ee3f4be6b8ad"
            "units" : "metric"
        ]
        AF.request("https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=51518b2be4cd74362f31ee3f4be6b8ad&lang=kr&units=metric", headers: headers).responseJSON{response in
            
            //데이터 저장
            switch response.result {
            case .success(let data) :
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let decoder = JSONDecoder()
                    self.currentData = try decoder.decode(CurrentWeaterData.self, from: jsonData)
                    self.settings(self.currentData.weather[0], self.currentData.main)
                    
                } catch {
                    debugPrint(error)
                }
            case .failure(let data): print("fail")
            default: return
            }
        }
    }
        func settings(_ WData:WeatherData, _ TData:TempData) {
            //아이콘 설정
            if let url = URL(string: "https://openweathermap.org/img/wn/\(WData.icon)@2x.png"){
                icon.af.setImage(withURL: url)
                print(url)
            }
            //날씨 설정
            weather.text = WData.description
            //온도 설정
            temp.text = String(TData.temp)
            
            print(WData.description)
            print(TData.temp)
        }
    
}


extension ViewController:CLLocationManagerDelegate {
    func checkLocationAuth() {
        // 3.1
        guard CLLocationManager.locationServicesEnabled() else {
            // 시스템 설정으로 유도하는 커스텀 얼럿
            locationAlert()
            return
        }
        // 3.2
        let authorizationStatus: CLAuthorizationStatus
            
        // 앱의 권한 상태 가져오는 코드 (iOS 버전에 따라 분기처리)
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        }else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
            
        // 권한 상태값에 따라 분기처리를 수행하는 메서드 실행
        userCurrentLocationAuth(authorizationStatus)
    }
    
    func userCurrentLocationAuth(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // 사용자가 권한에 대한 설정을 선택하지 않은 상태
            
            // 권한 요청을 보내기 전에 desiredAccuracy 설정 필요
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // 권한 요청
            locationManager.requestWhenInUseAuthorization()
                
        case .denied, .restricted:
            // 권한이 없는 상태
            locationAlert()
            
        case .authorizedWhenInUse:
            // 앱을 사용중일 때, 위치 서비스를 이용할 수 있는 상태: 위치 가져오기
            locationManager.startUpdatingLocation()
            
        default:
            print("Default")
        }
    }
    
    func locationAlert() {
        let locationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default) { [weak self] _ in
            //async { await self?.reloadData() }
        }
        locationServiceAlert.addAction(cancel)
        locationServiceAlert.addAction(goSetting)
        
        present(locationServiceAlert, animated: true)
    }
    
    // 사용자의 위치를 성공적으로 가져왔을 때 호출
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            if let coordinate = locations.last?.coordinate {
                self.getData(coordinate)
            }
            
            // startUpdatingLocation()을 사용하여 사용자 위치를 가져왔다면
            // 불필요한 업데이트를 방지하기 위해 stopUpdatingLocation을 호출
            locationManager.stopUpdatingLocation()
        }
    
        // 위치 정보를 가져오지 못했을 때 호출
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
        }
        
        // 앱에 대한 권한 설정이 변경되면 호출
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            //위치 서비스가 활성화 상태인지 확인
            checkLocationAuth()
        }
        
        // 앱에 대한 권한 설정이 변경되면 호출 (iOS 14 미만)
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            // 위치 서비스가 활성화 상태인지 확인
            checkLocationAuth()
        }
}



