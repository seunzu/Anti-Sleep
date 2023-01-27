//
//  NotificationView.swift
//  AntiSleep WatchKit Extension
//
//  Created by 주세연 on 2023/01/27.
//

import SwiftUI

struct NotificationView: View {
  var title: String?
  var message: String?
  
  
  var body: some View {
      
      Text(title ?? "AntiSleep")
        .font(.headline)
      
      Divider()
      
      Text(message ?? "심박수가 20 감소했습니다 졸음운전이 의심됩니다")
        .font(.caption)
    .lineLimit(0)
  }
}

//struct NotificationView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
