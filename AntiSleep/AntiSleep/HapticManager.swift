//
//  HapticManager.swift
//  AntiSleep
//
//  Created by 주세연 on 2023/01/31.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    public func selectVibrate() {
        DispatchQueue.main.sync {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(type)
        }
    }
}

