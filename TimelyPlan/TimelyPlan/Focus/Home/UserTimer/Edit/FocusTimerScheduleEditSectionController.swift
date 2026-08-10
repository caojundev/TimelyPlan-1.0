//
//  FocusTimerScheduleEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/14.
//

import Foundation
import UIKit

class FocusTimerScheduleEditSectionController: DateFrequencySectionController {
    
    var startTime: Int64 = Int64(8 * SECONDS_PER_HOUR)
    
    var onStartTimeChanged: ((Int64) -> Void)?
    
    /// 日期
    private var date: Date? {
        if startTime >= 0 {
            return .dateWithTimeOffset(Duration(startTime))
        }
        
        return nil
    }
    
    /// 时间单元格条目
    private lazy var timeCellItem: TPImageInfoTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "schedule_time_24"
        cellItem.updater = {
            guard let self = self else { return }
            if let date = self.date {
                self.timeCellItem.title = date.timeString
            } else {
                self.timeCellItem.title = resGetString("All Day")
            }
        }
        
        cellItem.didSelectHandler = {
            self?.editTime()
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.frequencyCellItem.imageName = "schedule_repeat_24"
        self.cellItems = [dateRangeCellItem,
                          frequencyCellItem,
                          timeCellItem]
    }
    
    // MARK: - Edit
    /// 编辑时间
    private func editTime() {
        let timePicker = TPTimePickerViewController()
        timePicker.date = date ?? .now
        timePicker.didPickDate = { date in
            self.pickTime(date)
        }
        
        timePicker.didClickClear = {
            self.pickTime(nil)
        }
        
        timePicker.popoverShowAsNavigationRoot()
    }
    
    /// 选中时间
    private func pickTime(_ date: Date?) {
        let offset: Int64
        if let date = date {
            offset = Int64(date.offset())
        } else {
            offset = -1
        }
        
        if startTime != offset {
            startTime = offset
            onStartTimeChanged?(startTime)
            adapter?.reloadCell(forItem: timeCellItem, with: .none)
        }
    }
    
}
