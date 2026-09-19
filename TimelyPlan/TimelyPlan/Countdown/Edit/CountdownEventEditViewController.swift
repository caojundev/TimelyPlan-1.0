//
//  CountdownEventEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

class CountdownEventEditViewController: TPTableSectionsViewController {
    
    struct Config {
        static let sectionHeaderPadding = UIEdgeInsets(top: 15.0,
                                                        left: 0.0,
                                                        bottom: 0.0,
                                                        right: 16.0)
        
        
        static let defaultCellHeight = 55.0
    }
    
    /// 编辑事件
    var editingEvent: CountdownEditingEvent
    
    /// 结束编辑回调
    var didEndEditing: ((CountdownEditingEvent) -> Void)?
    
    /// 编辑类型
    var editType: EditType = .create
    
    // MARK: - 图标和名称
    lazy var iconNameSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.cellItems = [emojiNameCellItem]
        return sectionController
    }()
    
    lazy var emojiNameCellItem: TPEmojiTextEditTableCellItem = { [weak self] in
        let cellItem = TPEmojiTextEditTableCellItem()
        cellItem.placeholder = resGetString("Fill in the countdown name")
        cellItem.clearButtonMode = .never
        cellItem.textAlignment = .center
        cellItem.updater = {
            self?.updateEmojiNameCellItem()
        }
        
        cellItem.emojiChanged = { emoji in
            self?.emojiChanged(emoji)
        }
        
        cellItem.editingChanged = { textField in
            let name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.nameEditingChanged(name)
        }
        
        return cellItem
    }()
    
    // MARK: - 颜色
    lazy var colorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.cellItems = [colorSelectCellItem]
        return sectionController
    }()
    
    lazy var colorSelectCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = CountdownConfig.countdownEventColors
        cellItem.updater = {
            self?.colorSelectCellItem.selectedColor = self?.editingEvent.color
        }
        
        cellItem.didSelectColor = { color in
            self?.editingEvent.color = color
        }
        
        return cellItem
    }()
    
    // MARK: - 通用
    lazy var generalSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.cellItems = [eventTypeCellItem,
                                       timeUnitCellItem,
                                       includesStartDateCellItem]
        return sectionController
    }()
    
    /// 类型
    lazy var eventTypeCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Type")
        cellItem.updater = {
            guard let self = self else { return }
            let text = self.editingEvent.type.title
            self.eventTypeCellItem.valueConfig = .valueText(text)
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
            let text = self.editingEvent.timeUnit.title
            self.timeUnitCellItem.valueConfig = .valueText(text)
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editTimeUnit()
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
            self.includesStartDateCellItem.isOn = self.editingEvent.includesStartDate
        }
        
        cellItem.valueChanged = { [weak self] isOn in
            self?.editingEvent.includesStartDate = isOn
        }
        
        return cellItem
    }()
    
    // MARK: - 显示方式
    lazy var displaySectionController: CountdownDisplayEditSectionController = {
        let sectionController = CountdownDisplayEditSectionController()
        sectionController.myDayDisplayMode = self.editingEvent.myDayDisplayMode
        sectionController.calendarDisplayMode = self.editingEvent.calendarDisplayMode
        
        sectionController.onMyDayDisplayModeChanged = { [weak self] mode in
            self?.editingEvent.myDayDisplayMode = mode
        }
        
        sectionController.onCalendarDisplayModeChanged = { [weak self] mode in
            self?.editingEvent.calendarDisplayMode = mode
        }
        
        return sectionController
    }()
    
    // MARK: - 目标日期
    lazy var targetDateSectionController: CountdownDateEditSectionController = {
        let sectionController = CountdownDateEditSectionController()
        sectionController.date = self.editingEvent.date
        sectionController.timePlan = self.editingEvent.timePlan
        sectionController.reminder = self.editingEvent.reminder
        
        sectionController.onDateChanged = { [weak self] date in
            self?.editingEvent.date = date
        }
        
        sectionController.onTimePlanChanged = { [weak self] timePlan in
            self?.editingEvent.timePlan = timePlan
        }
        
        sectionController.onReminderChanged = { [weak self] reminder in
            self?.editingEvent.reminder = reminder
        }
        
        return sectionController
    }()
    
    // MARK: - 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.noteCellItem.updater = {
            self?.noteSectionController.note = self?.editingEvent.note
        }
        
        sectionController.noteEditingChanged = { note in
            self?.editingEvent.note = note
        }
        
        return sectionController
    }()
    
    init(event: CountdownEditingEvent? = nil,
         editType: EditType? = nil) {
        self.editingEvent = event ?? CountdownEditingEvent()
        /// 外部未指定时，仍根据是否传入事件判断编辑类型
        self.editType = editType ?? (event != nil ? .modify : .create)
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        updateTitle()
        
        wrapperView.isKeyboardAdjusterEnabled = true /// 键盘自动调整开启
        tableView.keyboardDismissMode = .onDrag
        let sectionControllers = [iconNameSectionController,
                                  colorSectionController,
                                  targetDateSectionController,
                                  generalSectionController,
                                  displaySectionController,
                                  noteSectionController]
        self.sectionControllers = sectionControllers
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        reloadData()
        
        updateDoneButtonEnabled()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func handleFirstAppearance() {
        /// 当前名称为空，开始编辑名称
        beginNameEditingIfNeeded()
        /// 将选中颜色滚动到可视位置
        scrollSelectedColorToVisible()
    }
    
    // MARK: - UI Update
    func updateTitle() {
        if editType == .create {
            self.title = resGetString("New Countdown")
        } else {
            self.title = resGetString("Edit Countdown")
        }
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        doneBarButtonItem.isEnabled = isDoneButtonItemEnabled()
    }
    
    func isDoneButtonItemEnabled() -> Bool {
        return !isEmptyName
    }
    
    /// 名称是否为空
    var isEmptyName: Bool {
        if let name = editingEvent.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            return false
        }
        
        return true
    }
    
    /// 当前名称为空时编辑名称
    func beginNameEditingIfNeeded() {
        if isEmptyName {
            beginNameEditing()
        }
    }
    
    /// 开始名称编辑
    func beginNameEditing() {
        if let cell = adapter.cellForItem(emojiNameCellItem) as? TPTextFieldTableCell {
            cell.textField.becomeFirstResponder()
        }
    }
    
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorSelectCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
    
    override func clickDone() {
        /// 取消第一响应者
        UIResponder.resignCurrentFirstResponder()
        self.didEndEditing?(self.editingEvent)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 图标和名称
    /// 更新名称和图标条目数据
    func updateEmojiNameCellItem() {
        emojiNameCellItem.emoji = editingEvent.emoji.first
        emojiNameCellItem.text = editingEvent.name
    }
    
    /// 选中图标
    func emojiChanged(_ emoji: Character?) {
        guard let emoji = emoji else {
            return
        }
        
        editingEvent.emoji = String(emoji)
    }
    
    /// 名称编辑改变
    func nameEditingChanged(_ name: String?) {
        self.editingEvent.name = name
        updateDoneButtonEnabled()
    }
    
    private func editEventType() {
        guard let cell = adapter.cellForItem(eventTypeCellItem) else {
            return
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 180.0
        let menuItem = TPMenuItem.item(with: CountdownEventType.allCases,
                                       updater: { type, action in
            action.title = type.emojiTitle
            action.handleBeforeDismiss = true
            action.isChecked = type == self.editingEvent.type
        })
        
        menuList.didSelectMenuAction = { action in
            guard let type: CountdownEventType = action.actionType() else {
                return
            }
            
            self.selectEventType(type)
        }
        
        menuList.menuItems = [menuItem]
        menuList.popoverShow(from: cell,
                             sourceRect: cell.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft,
                             permittedPositions: [.bottomLeft, .topLeft])
    }
    
    private func selectEventType(_ type: CountdownEventType) {
        guard editingEvent.type != type else {
            return
        }
        
        editingEvent.type = type
        adapter.reloadCell(forItem: eventTypeCellItem, with: .none)
    }
    
    private func editTimeUnit() {
        guard let cell = adapter.cellForItem(timeUnitCellItem) else {
            return
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 180.0
        let menuItem = TPMenuItem.item(with: CountdownTimeUnit.allCases,
                                       updater: { unit, action in
            action.title = unit.title
            action.handleBeforeDismiss = true
            action.isChecked = unit == self.editingEvent.timeUnit
        })
        
        menuList.didSelectMenuAction = { action in
            guard let unit: CountdownTimeUnit = action.actionType() else {
                return
            }
            
            self.selectTimeUnit(unit)
        }
        
        menuList.menuItems = [menuItem]
        menuList.popoverShow(from: cell,
                             sourceRect: cell.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft,
                             permittedPositions: [.bottomLeft, .topLeft])
    }
    
    private func selectTimeUnit(_ unit: CountdownTimeUnit) {
        guard editingEvent.timeUnit != unit else {
            return
        }
        
        editingEvent.timeUnit = unit
        adapter.reloadCell(forItem: timeUnitCellItem, with: .none)
    }
}
