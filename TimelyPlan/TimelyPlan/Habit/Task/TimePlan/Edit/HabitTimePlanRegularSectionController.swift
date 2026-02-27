//
//  HabitTimePlanRegularSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/5.
//

import Foundation
import UIKit

class HabitTimePlanRegularSectionController: TPTableItemSectionController {
    
    /// 规则变化
    var ruleDidChange: ((HabitTimePlanRegularRule) -> Void)?

    /// 规则
    var rule: HabitTimePlanRegularRule {
        get {
            return HabitTimePlanRegularRule(frequency: frequency,
                                       interval: interval,
                                       daysOfTheWeek: daysOfTheWeek,
                                       daysOfTheMonth: daysOfTheMonth)
        }
        
        set {
            frequency = newValue.frequency
            interval = newValue.interval
            daysOfTheWeek = newValue.daysOfTheWeek ?? [Weekday(date: .now)]
            daysOfTheMonth = newValue.daysOfTheMonth ?? [Date.now.day]
        }
    }

    /// 频率
    private var frequency: RepeatFrequency = .daily
    
    /// 重复间隔
    private var interval: Int = 1
    
    /// 与定期规则关联的周中的几天
    private var daysOfTheWeek: [Weekday] = []
    
    /// 与定期规则关联的月份中的几天,（1～31，-1表示最后一天）
    private var daysOfTheMonth: [Int] = []

    /// 重复频率
    private let frequencies: [RepeatFrequency] = [.daily,
                                                  .weekly,
                                                  .monthly]
    
    /// 频率
    lazy var frequencyCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = kInsetGroupedSegmentedMenuCornerRadius
        cellItem.menuItems = frequencies.segmentedMenuItems()
        cellItem.updater = {
            self?.updateFrequencyCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let frequency: RepeatFrequency? = menuItem.actionType()
            if let frequency = frequency {
                self?.didSelectFrequency(frequency)
            }
        }
        
        return cellItem
    }()
    
    lazy var intervalCellItem: TPCountPickerTableCellItem = { [weak self] in
        let cellItem = TPCountPickerTableCellItem()
        cellItem.height = 240.0
        cellItem.updater = {
            self?.updateIntervalCellItem()
        }
        
        cellItem.leadingTextForCount = { _ in
            return resGetString("Every")
        }
        
        cellItem.didPickCount = { [weak self] count in
            self?.didSelectInterval(count)
        }

        return cellItem
    }()
    
    lazy var daysOfWeekCellItem: RepeatDayOfWeekTableCellItem = {  [weak self] in
        let cellItem = RepeatDayOfWeekTableCellItem()
        cellItem.contentPadding = UIEdgeInsets(vertical: 12.0)
        cellItem.height = 80.0
        cellItem.updater = {
            self?.updateWeekdaysCellItem()
        }
        
        cellItem.daysChangedHandler = { weekdays in
            self?.didSelectDaysOfTheWeek(Array(weekdays))
        }
        
        return cellItem
    }()
    
    lazy var daysOfMonthCellItem: RepeatDayOfMonthTableCellItem = { [weak self] in
        let cellItem = RepeatDayOfMonthTableCellItem()
        cellItem.updater = {
            self?.updateDaysOfMonthCellItem()
        }
        
        cellItem.didSelectDaysOfMonth = { days in
            self?.didSelectDaysOfTheMonth(Array(days))
        }
        
        return cellItem
    }()

    override init() {
        super.init()
    }
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var cellItems: [TPBaseTableCellItem] = [frequencyCellItem]
            switch frequency {
            case .daily:
                cellItems.append(intervalCellItem)
            case .weekly:
                cellItems.append(daysOfWeekCellItem)
            case .monthly:
                cellItems.append(daysOfMonthCellItem)
            default:
                break
            }
            
            return cellItems
        }
        
        set {}
    }
    
    // MARK: - Update CellItems
    func updateFrequencyCellItem() {
        frequencyCellItem.selectedMenuTag = frequency.rawValue
    }
    
    func updateIntervalCellItem() {
        intervalCellItem.tailingTextForCount =  { [weak self] count in
            return self?.frequency.localizedUnit(for: count)
        }
        
        intervalCellItem.minimumCount = 1
        intervalCellItem.maximumCount = 7
        intervalCellItem.count = max(1, min(interval, 7))
    }
    
    func updateWeekdaysCellItem() {
        daysOfWeekCellItem.days = Set(daysOfTheWeek)
    }
    
    func updateDaysOfMonthCellItem() {
        daysOfMonthCellItem.days = Set(daysOfTheMonth)
    }
    
    // MARK: - 选中方法
    func didSelectFrequency(_ frequency: RepeatFrequency) {
        self.frequency = frequency
        if frequency != .daily {
            self.interval = 1 /// 周和月间隔设定为1
        }
        
        self.ruleDidChange?(rule)
        self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
        self.adapter?.reloadCell(forItem: self.intervalCellItem, with: .none)
    }
    
    func didSelectInterval(_ interval: Int) {
        self.interval = interval
        ruleDidChange?(rule)
    }
    
    func didSelectDaysOfTheWeek(_ weekdays: [Weekday]) {
        self.daysOfTheWeek = weekdays
        ruleDidChange?(rule)
    }
    
    func didSelectDaysOfTheMonth(_ days: [Int]) {
        self.daysOfTheMonth = days
        ruleDidChange?(rule)
    }
}
