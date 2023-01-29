//
//  timeTriggerController.swift
//  AntiSleep WatchKit Extension
//
//  Created by suhseungju on 2023/01/25.
//

import WatchKit
import Foundation

class timeTriggerController: WKInterfaceController {
    var timeTrigger = true
    var realTime = Timer()
    var sumTime : Int = 0
    var sumTime2 : Int = 0
    var goalTime : Int = 0
    
    
    func checkTimeTrigger() {
        realTime = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: false)
    }
    
    @objc func updateCounter() {
        sumTime += 1
        
    
    }
    
    @IBAction func StartBtnAction(_ sender: UIButton) {
        algoOfStart()
    }
    @IBAction func StopBtnAction(_ sender: UIButton) {
        algoOfStop()
    }
    
}

extension timeTriggerController {
    func algoOfStart() {
        isStop = false
        startAction()
        finishTimeLabel.text = getFutereTime()
        if (isFirst) {
            firstStart()
            isFirst = false
        }
    }
    
    func algoOfStop)( {
        isStop = true
        timeTrigger = true
        realTime.invalidate()
        
        saveLogData()
        saveStopCount()
        setAverage()
        setTimes()
        
        stopEnable()
        
    }
}
