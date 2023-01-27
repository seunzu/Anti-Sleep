//
//  Structs.swift
//  WeatherTest
//
//  Created by yeseo on 2023/01/23.
//

import UIKit

struct CurrentWeaterData:Codable {
    
    let weather: [WeatherData]
    let base:String //내부 매개변수
    let main:TempData
    let visibility:Int //가시성
    let clouds: CloudsData?
    let dt:Int //데이터 계산 시간, UTC
    let sys: SysData
    let timezone: Int //UTC -> 초단위
    let id: Int //도시 아이디
    let name: String //도시 이름
    let cod: Int //내부 매개변수
    
}


struct WeatherData:Codable {
    let id: Int //날씨 조건 id
    let main:String //날씨: 비, 눈 등 대략적 날씨
    let description:String //날씨: main 안에서 더 세부적인 날씨 표현(가벼운 눈 등)
    let icon: String //날씨 아이콘
}

struct TempData:Codable {
    let temp: Float //온도(섭씨 단위)
    let feels_like:  Float //체감온도
    let temp_min:  Float //최저기온
    let temp_max: Float //최고기온
    let pressure:  Float //대기압
    let humidity:  Float //습도
    let sea_level:  Float? //해수면 대기압
    let grnd_level:  Float? //지상 대기압
}


struct CloudsData:Codable {
    let all:Int? //흐린 정도(%)
}

struct SysData:Codable {
    let type: Int //내부 매개변수
    let id: Int //내부 매개변수
    let country: String //국가 코드
    let sunrise: Int //일출 시간
    let sunset: Int //일몰 시간
}
