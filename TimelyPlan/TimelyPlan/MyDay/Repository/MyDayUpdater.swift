//
//  MyDayUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

protocol MyDayEventChangeDelegate: AnyObject {
    
    /// 我的一天事项发生改变时触发
    func myDayEventsDidChange(in ranges: [DateInterval])
}

class MyDayUpdater: NSObject, MyDayEventChangeDelegate {
    
    func myDayEventsDidChange(in ranges: [DateInterval]) {
        notifyDelegates { (delegate: MyDayEventChangeDelegate) in
            delegate.myDayEventsDidChange(in: ranges)
        }
    }
}
