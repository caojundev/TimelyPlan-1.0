//
//  HabitReportContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitReportContentViewController: StatsContentViewController,
                                        HabitRecordProcessorDelegate {
    
    let imageCacher = HabitReportImageCacher()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentInset = UIEdgeInsets(bottom: 80.0)
        let emptyImage = resGetImage("placeholder_record_80")
        var emptyTitle: String?
        switch self.type {
        case .day:
            break
        case .week:
            emptyTitle = resGetString("No Report This Week")
        case .month:
            emptyTitle = resGetString("No Report This Month")
        case .year:
            emptyTitle = resGetString("No Report This Year")
        }
                
        self.placeholderProvider.emptyImage = emptyImage
        self.placeholderProvider.emptyTitle = emptyTitle
        habit.addUpdater(self, for: [.record])
    }

    // MARK: - HabitRecordProcessorDelegate
    /// 通知习惯记录已更新
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        
    }
    
    /// 通知习惯记录删除
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        
    }
}
