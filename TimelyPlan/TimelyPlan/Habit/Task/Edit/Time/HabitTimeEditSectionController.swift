//
//  HabitTimeEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/14.
//

import Foundation

class HabitTimeEditSectionController: TPTableItemSectionController {
    
    var onTimeOptionChanged: ((HabitTimeOption) -> Void)?
    
    var onStartTimeChanged: ((Int64) -> Void)?
    
    var onDurationChanged: ((Int64) -> Void)?
    
    private(set) var timeOption: HabitTimeOption {
        didSet {
            if timeOption != oldValue {
                onTimeOptionChanged?(timeOption)
            }
        }
    }
    
    private(set) var startTime: Int64 {
        didSet {
            if startTime != oldValue {
                onStartTimeChanged?(startTime)
            }
        }
    }
    
    private(set) var duration: Int64 {
        didSet {
            if duration != oldValue {
                onDurationChanged?(duration)
            }
        }
    }
    
    private var startDate: Date {
        return .dateWithTimeOffset(Duration(startTime))
    }
    
    private var endDate: Date {
        let startDate = startDate
        let seconds = Int(duration)
        guard let endDate = startDate.dateByAddingSeconds(seconds) else {
            return startDate
        }
        
        return endDate
    }
    
    /// 时间选择
    lazy var timeEditCellItem: HabitTimeEditTableCellItem = { [weak self] in
        let cellItem = HabitTimeEditTableCellItem()
        cellItem.updater = {
            guard let self = self else { return }
            cellItem.selectedOption = self.timeOption
        }
        
        cellItem.didSelectTimeOption = { timeOption in
            self?.selectTimeOption(timeOption)
        }
        
        return cellItem
    }()
    
    /// 时间单元格条目
    private lazy var timeCellItem: TPImageInfoTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
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
    lazy var durationCellItem: TPImageInfoTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "schedule_duration_24"
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
            var items: [TPBaseTableCellItem] = [timeEditCellItem]
            if timeOption != .anytime {
                items.append(timeCellItem)
                items.append(durationCellItem)
            }
            
            return items
        }
        
        set {}
    }
    
    init(timeOption: HabitTimeOption,
         startTime: Int64,
         duration: Int64) {
        self.timeOption = timeOption
        self.startTime = startTime
        self.duration = duration
        super.init()
    }
 
    /// 更新时间单元格条目
    private func updateTimeCellItem() {
        if timeOption == .anytime {
            timeCellItem.title = resGetString("All Day")
        } else {
            let format = resGetString("Start %@")
            timeCellItem.title = String(format: format, startDate.timeString)
        }
    }
    
    /// 更新时长单元格
    private func updateDurationCellItem() {
        let startDate = startDate
        let endDate = endDate
        
        let title = "\(Duration(duration).localizedTitle) → \(endDate.timeString)"
        let daysCount = startDate.daysBetween(endDate)
        if daysCount > 0 {
            let badgeString = "+\(daysCount)"
            let attributedTitle = title.byAppend(badge: badgeString,
                                                 baselineOffset: 6.0,
                                                 font: .boldSystemFont(ofSize: 8.0),
                                                 color: resGetColor(.title))
            durationCellItem.title = attributedTitle
        } else {
            durationCellItem.title = title
        }
    }
    
    private let defaultDuration = 5 * SECONDS_PER_MINUTE
    
    // MARK: - Edit
    private func selectTimeOption(_ timeOption: HabitTimeOption) {
        guard self.timeOption != timeOption else {
            return
        }
        
        if self.timeOption == .anytime, self.duration == 0 {
            /// 从任意时间切换到具体时间
            self.duration = Int64(defaultDuration)
        }
        
        self.startTime = Int64(timeOption.presetHour * SECONDS_PER_HOUR)
        self.timeOption = timeOption
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
    }

    /// 编辑时间
    private func editTime() {
        let timePicker = TPTimePickerViewController()
        timePicker.date = startDate
        timePicker.didPickDate = { date in
            self.didPickTime(date)
        }
        
        timePicker.popoverShow()
    }
    
    /// 选中时间
    private func didPickTime(_ date: Date) {
        startTime = Int64(date.offset())
        timeOption = HabitTimeOption.currentPeriod(from: date)
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .none,
                                      completion: nil)
    }

    // MARK: - 持续时长
    private func editDuration() {
        let pickerVC = TPDurationPickerViewController()
        pickerVC.minimumDuration = SECONDS_PER_MINUTE
        pickerVC.duration = Int(duration)
        pickerVC.didPickDuration = { duration in
            self.selectDuration(duration)
        }
    
        pickerVC.popoverShow()
    }
    
    private func selectDuration(_ duration: Duration) {
        self.duration = Int64(duration)
        adapter?.reloadCell(forItems: [timeCellItem, durationCellItem], with: .none)
    }
}
