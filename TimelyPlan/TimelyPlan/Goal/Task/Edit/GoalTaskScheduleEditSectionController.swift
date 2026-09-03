//
//  GoalTaskScheduleEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/3.
//

import Foundation
import UIKit

class GoalTaskScheduleEditSectionController: DateFrequencySectionController {
    
    var onStartTimeChanged: ((Int64) -> Void)?
    
    var onDurationChanged: ((Int64) -> Void)?
    
    var startTime: Int64 = -1
    
    var duration: Int64 = 60

    /// 日期
    private var startDate: Date? {
        if startTime >= 0 {
            return .dateWithTimeOffset(Duration(startTime))
        }
        
        return nil
    }
    
    private var endDate: Date? {
        guard let startDate = startDate else {
            return nil
        }
        
        let seconds = Int(duration)
        guard let endDate = startDate.dateByAddingSeconds(seconds) else {
            return startDate
        }
        
        return endDate
    }
    
    /// 时间单元格条目
    private(set) lazy var timeCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "schedule_time_24"
        cellItem.updater = {
            self?.updateTimeCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editTime()
        }
        
        return cellItem
    }()
    
    /// 持续时长
    lazy var durationCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "schedule_duration_24"
        cellItem.title = resGetString("Duration")
        cellItem.updater = {
            self?.updateDurationCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editDuration()
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var items: [TPBaseTableCellItem] = [dateRangeCellItem,
                                                frequencyCellItem,
                                                timeCellItem]
            if startDate != nil {
                items.append(durationCellItem)
            }
        
            return items
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.frequencyCellItem.imageName = "schedule_repeat_24"
        self.dateRangeCellItem.canDeleteEnd = false
    }
    
    
    // MARK: - Update
    /// 更新时间单元格条目
    private func updateTimeCellItem() {
        if let startDate = self.startDate {
            timeCellItem.title = resGetString("Start Time")
            timeCellItem.valueConfig = .valueText(startDate.timeString)
        } else {
            timeCellItem.title = resGetString("All Day")
            timeCellItem.valueConfig = .valueText(nil)
        }
    }
    
    /// 更新时长单元格
    private func updateDurationCellItem() {
        guard let startDate = startDate, let endDate = endDate else {
            durationCellItem.valueConfig = .valueText(nil)
            return
        }
        
        let title = "\(Duration(duration).localizedTitle) → \(endDate.timeString)"
        let daysCount = startDate.daysBetween(endDate)
        let valueText: TextRepresentable
        if daysCount > 0 {
            let badgeString = "+\(daysCount)"
            valueText = title.byAppend(badge: badgeString,
                                       baselineOffset: 6.0,
                                       font: .boldSystemFont(ofSize: 8.0),
                                       color: .secondaryLabel)
        } else {
            valueText = title
        }
        
        durationCellItem.valueConfig = .valueText(valueText)
    }
    
    
    // MARK: - Edit
    /// 编辑时间
    private func editTime() {
        let timePicker = TPTimePickerViewController()
        timePicker.date = startDate ?? .now
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
            adapter?.performSectionUpdate(forSectionObject: self,
                                          rowAnimation: .fade,
                                          completion: nil)
        }
    }
    
    // MARK: - 持续时长
    func editDuration() {
        let pickerVC = TPDurationPickerViewController()
        pickerVC.minimumDuration = SECONDS_PER_MINUTE
        pickerVC.duration = Int(duration)
        pickerVC.didPickDuration = { duration in
            self.selectDuration(duration)
        }
    
        pickerVC.popoverShow()
    }
    
    func selectDuration(_ duration: Duration) {
        guard self.duration != duration else {
            return
        }
        
        self.duration = Int64(duration)
        onDurationChanged?(self.duration)
        adapter?.reloadCell(forItems: [timeCellItem, durationCellItem], with: .none)
    }
    
}
