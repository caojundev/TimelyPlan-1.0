//
//  HabitTimeEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/14.
//

import Foundation

class HabitTimeEditSectionController: TPTableItemSectionController {
    
    var onTimeOptionChanged: ((HabitTimeOption) -> Void)?
    
    var timeOption: HabitTimeOption = .anytime
    
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
    
    
    var startDate: Date = .now
    var duration: Duration = SECONDS_PER_DAY
    
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
    
    override init() {
        super.init()
    }
 
    private func selectTimeOption(_ timeOption: HabitTimeOption) {
        guard self.timeOption != timeOption else {
            return
        }
        
        self.timeOption = timeOption
        /// 更新日期
        startDate = startDate.dateByReplacingHour(with: timeOption.presetHour)
        
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
        onTimeOptionChanged?(timeOption)
        
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
        guard let endDate = startDate.dateByAddingSeconds(duration) else {
            return
        }
        
        let title = "\(duration.localizedTitle) → \(endDate.timeString)"
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
    
    // MARK: - Edit

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
        startDate = date
        adapter?.reloadCell(forItems: [timeCellItem, durationCellItem],
                            with: .none)
    }

    // MARK: - 持续时长
    private func editDuration() {
        let pickerVC = TPDurationPickerViewController()
        pickerVC.minimumDuration = SECONDS_PER_MINUTE
        pickerVC.duration = duration
        pickerVC.didPickDuration = { duration in
            self.selectDuration(duration)
        }
    
        pickerVC.popoverShow()
    }
    
    private func selectDuration(_ duration: Duration) {
        self.duration = duration
        adapter?.reloadCell(forItems: [timeCellItem, durationCellItem],
                            with: .none)
    }

}
