//
//  CountdownGeneralEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/21.
//

import Foundation
import UIKit

/// 倒数日常规编辑区块
/// 负责事件类型、时间单位、计数类型与“包含起始日”的编辑与显隐，
class CountdownGeneralEditSectionController: TPTableItemSectionController {
    
    struct Config {
        /// 区块顶部间距
        static let sectionHeaderHeight = 15.0
        
        static let defaultCellHeight = 55.0
        
        /// 菜单内容宽度
        static let menuContentWidth = 180.0
    }
    
    /// 事件类型改变回调
    var onEventTypeChanged: ((CountdownEventType) -> Void)?
    
    /// 时间单位改变回调
    var onTimeUnitChanged: ((CountdownTimeUnit) -> Void)?
    
    /// 计数类型改变回调
    var onCountingTypeChanged: ((CountdownEvent.CountingType) -> Void)?
    
    /// 包含起始日改变回调
    var onIncludesStartDateChanged: ((Bool) -> Void)?
    
    /// 事件类型
    var eventType: CountdownEventType = .countdown
    
    /// 时间单位
    var timeUnit: CountdownTimeUnit = .days
    
    /// 计数类型（倒数 / 正数）
    var countingType: CountdownEvent.CountingType = .countdown
    
    /// 正数计数是否包含选中日期当天（+1）
    var includesStartDate: Bool = false
    
    /// 目标日期（用于判断日期是否已过去）
    var date: CountdownDate = CountdownDate()
    
    /// 时间计划（nil 表示不重复）
    var timePlan: CountdownTimePlan?
    
    // MARK: - 显隐条件
    /// 目标日期是否已过去
    var isPastDate: Bool {
        return date.targetDate < Date().startOfDay()
    }
    
    /// 是否存在重复规则
    var hasRepeat: Bool {
        guard let type = timePlan?.type else {
            return false
        }
        
        return type != .none
    }
    
    /// 是否显示计数类型（过去日期 + 重复）
    var showsCountingTypeCellItem: Bool {
        return isPastDate && hasRepeat
    }
    
    /// 是否显示包含起始日
    /// 过去日期 + 重复 + 正数，或过去日期但无重复
    var showsIncludesStartDateCellItem: Bool {
        guard isPastDate else {
            return false
        }
        
        guard hasRepeat else {
            return true
        }
        
        return countingType == .countUp
    }
    
    // MARK: - 单元格
    /// 类型
    lazy var eventTypeCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Type")
        cellItem.updater = {
            guard let self = self else { return }
            self.eventTypeCellItem.valueConfig = .valueText(self.eventType.title)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editEventType()
        }
        
        return cellItem
    }()
    
    /// 时间单位
    lazy var timeUnitCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Time Unit")
        cellItem.updater = {
            guard let self = self else { return }
            self.timeUnitCellItem.valueConfig = .valueText(self.timeUnit.title)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editTimeUnit()
        }
        
        return cellItem
    }()
    
    /// 计数类型（倒数 / 正数）
    lazy var countingTypeCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.cornerRadius = AppLayout.Cell.segmentedMenuCornerRadius
        cellItem.menuItems = CountdownEvent.CountingType.segmentedMenuItems()
        cellItem.updater = {
            self?.countingTypeCellItem.selectedMenuTag = self?.countingType.tag ?? 0
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let countingType: CountdownEvent.CountingType? = menuItem.actionType()
            if let countingType = countingType {
                self?.selectCountingType(countingType)
            }
        }
        
        return cellItem
    }()
    
    /// 正数计数是否包含选中日期当天（+1）
    lazy var includesStartDateCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.title = resGetString("Include Start Date")
        cellItem.subtitle = resGetString("Count start date as Day 1")
        cellItem.subtitleConfig.font = .boldSystemFont(ofSize: 11.0)
        cellItem.updater = {
            guard let self = self else { return }
            self.includesStartDateCellItem.isOn = self.includesStartDate
        }
        
        cellItem.valueChanged = { [weak self] isOn in
            self?.includesStartDate = isOn
            self?.onIncludesStartDateChanged?(isOn)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.headerItem.height = Config.sectionHeaderHeight
        self.footerItem.height = 0.0
        self.updateCellItems()
    }
    
    // MARK: - 单元格条目
    /// 根据日期、重复规则与计数类型刷新单元格条目
    func updateCellItems() {
        var items: [TPBaseTableCellItem] = []
        if showsCountingTypeCellItem {
            items.append(countingTypeCellItem)
        }
        
        if showsIncludesStartDateCellItem {
            items.append(includesStartDateCellItem)
        }
        
        items.append(timeUnitCellItem)
        items.append(eventTypeCellItem)
        self.cellItems = items
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .fade)
    }
    
    // MARK: - 类型
    /// 编辑事件类型
    private func editEventType() {
        guard let cell = adapter?.cellForItem(eventTypeCellItem) else {
            return
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = Config.menuContentWidth
        let menuItem = TPMenuItem.item(with: CountdownEventType.allCases,
                                       updater: { [weak self] type, action in
            action.title = type.emojiTitle
            action.handleBeforeDismiss = true
            action.isChecked = type == self?.eventType
        })
        
        menuList.didSelectMenuAction = { [weak self] action in
            guard let type: CountdownEventType = action.actionType() else {
                return
            }
            
            self?.selectEventType(type)
        }
        
        menuList.menuItems = [menuItem]
        menuList.popoverShow(from: cell,
                             sourceRect: cell.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft,
                             permittedPositions: [.bottomLeft, .topLeft])
    }
    
    /// 选中事件类型
    func selectEventType(_ type: CountdownEventType) {
        guard eventType != type else {
            return
        }
        
        eventType = type
        onEventTypeChanged?(type)
        adapter?.reloadCell(forItem: eventTypeCellItem, with: .none)
    }
    
    // MARK: - 时间单位
    /// 编辑时间单位
    private func editTimeUnit() {
        guard let cell = adapter?.cellForItem(timeUnitCellItem) else {
            return
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = Config.menuContentWidth
        let menuItem = TPMenuItem.item(with: CountdownTimeUnit.allCases,
                                       updater: { [weak self] unit, action in
            action.title = unit.title
            action.handleBeforeDismiss = true
            action.isChecked = unit == self?.timeUnit
        })
        
        menuList.didSelectMenuAction = { [weak self] action in
            guard let unit: CountdownTimeUnit = action.actionType() else {
                return
            }
            
            self?.selectTimeUnit(unit)
        }
        
        menuList.menuItems = [menuItem]
        menuList.popoverShow(from: cell,
                             sourceRect: cell.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft,
                             permittedPositions: [.bottomLeft, .topLeft])
    }
    
    /// 选中时间单位
    func selectTimeUnit(_ unit: CountdownTimeUnit) {
        guard timeUnit != unit else {
            return
        }
        
        timeUnit = unit
        onTimeUnitChanged?(unit)
        adapter?.reloadCell(forItem: timeUnitCellItem, with: .none)
    }
    
    // MARK: - 计数类型
    /// 选中计数类型
    func selectCountingType(_ countingType: CountdownEvent.CountingType) {
        guard self.countingType != countingType else {
            return
        }
        
        self.countingType = countingType
        onCountingTypeChanged?(countingType)
        /// 计数类型影响“包含起始日”单元格的显隐
        updateCellItems()
    }
}
