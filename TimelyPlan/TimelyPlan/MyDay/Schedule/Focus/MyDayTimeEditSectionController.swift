//
//  MyDayTimeEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/2.
//

import Foundation
import UIKit

class MyDayTimeEditSectionController: TPTableItemSectionController {
    
    enum TimeType: Int, TPMenuRepresentable {
        case allDay
        case specificTime
        
        var title: String {
            switch self {
            case .allDay:
                return resGetString("All-Day")
            case .specificTime:
                return resGetString("Specific Time")
            }
        }
    }
    
    var onStartTimeChanged: ((Int64) -> Void)?
    
    /// 持续时长变化（仅在允许编辑时长时生效）
    var onDurationChanged: ((Int64) -> Void)?
    
    private(set) var startTime: Int64
    
    /// 持续时长（秒）
    var duration: Int64
    
    /// 是否允许编辑持续时长（目标任务可编辑，专注计时器不可编辑）
    let isDurationEditable: Bool
    
    /// 日期
    var date: Date? {
        if startTime >= 0 {
            return .dateWithTimeOffset(Duration(startTime))
        }
        
        return nil
    }
    
    /// 结束日期（根据开始时间与持续时长计算）
    private var endDate: Date? {
        guard let startDate = date else {
            return nil
        }
        
        let seconds = Int(duration)
        guard let endDate = startDate.dateByAddingSeconds(seconds) else {
            return startDate
        }
        
        return endDate
    }
    
    var timeType: TimeType {
        return date == nil ? .allDay : .specificTime
    }
    
    /// 时间类型
    lazy var timeTypeCellItem: MyDayTimeTypeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = MyDayTimeTypeSegmentedMenuTableCellItem()
        cellItem.menuItems = TimeType.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else { return }
            self.timeTypeCellItem.selectedMenuTag = self.timeType.rawValue
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let timeType: TimeType? = menuItem.actionType()
            if let timeType = timeType {
                self?.selectTimeType(timeType)
            }
        }
        
        return cellItem
    }()
    
    /// 时间选择器
    lazy var timePickerCellItem: TPTimePickerTableCellItem = { [weak self] in
        let cellItem = TPTimePickerTableCellItem()
        cellItem.height = 240.0
        cellItem.updater = {
            guard let self = self else { return }
            self.timePickerCellItem.date = self.date ?? .now
        }
        
        cellItem.didPickDate = { [weak self] date in
            self?.pickTime(date)
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
            var items: [TPBaseTableCellItem] = [timeTypeCellItem]
            if timeType == .specificTime {
                items.append(timePickerCellItem)
                if isDurationEditable {
                    items.append(durationCellItem)
                }
            }
            
            return items
        }
        
        set {}
    }
    
    init(startTime: Int64,
         duration: Int64 = 60,
         isDurationEditable: Bool = false) {
        self.startTime = startTime
        self.duration = duration
        self.isDurationEditable = isDurationEditable
        super.init()
    }
    
    private func selectTimeType(_ type: TimeType) {
        if type == .allDay {
            pickTime(nil)
        } else {
            pickTime(.now)
        }
        
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
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
        }
    }
    
    // MARK: - 持续时长
    /// 更新时长单元格
    private func updateDurationCellItem() {
        guard let startDate = date, let endDate = endDate else {
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
    
    /// 编辑持续时长
    private func editDuration() {
        let pickerVC = TPDurationPickerViewController()
        pickerVC.minimumDuration = SECONDS_PER_MINUTE
        pickerVC.duration = Int(duration)
        pickerVC.didPickDuration = { [weak self] duration in
            self?.selectDuration(duration)
        }
        
        pickerVC.popoverShow()
    }
    
    /// 选中持续时长
    private func selectDuration(_ duration: Duration) {
        guard self.duration != Int64(duration) else {
            return
        }
        
        self.duration = Int64(duration)
        onDurationChanged?(self.duration)
        adapter?.reloadCell(forItems: [durationCellItem], with: .none)
    }
}

class MyDayTimeTypeSegmentedMenuTableCellItem: TPFullSizeSegmentedMenuTableCellItem {
    
    override var minimumButtonWidth: CGFloat {
        get {
            guard let cellWidth = cellWidth else {
                return 0.0
            }
            
            let count = menuItems.count
            let minWidth = ((cellWidth - menuPadding.horizontalLength) - CGFloat(count - 1) * menuMargin) / CGFloat(count)
            return minWidth
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.height = 60.0
        self.menuPadding = UIEdgeInsets(value: 6.0)
        self.menuMargin = 6.0
        self.cornerRadius = 14.0
    }
}
