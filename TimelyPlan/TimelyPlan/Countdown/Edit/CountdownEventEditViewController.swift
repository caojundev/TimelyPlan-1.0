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
        static let sectionTitleHeaderHeight = 50.0
        
        static let sectionNormalHeaderHeight = 20.0
        
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
    
    // MARK: - 目标日期
    lazy var targetDateSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.title = resGetString("Target Date")
        sectionController.headerItem.height = Config.sectionTitleHeaderHeight
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [targetDateCellItem,
                                       repeatRuleCellItem]
        return sectionController
    }()
  
    lazy var targetDateCellItem: TPDefaultInfoTableCellItem = { [weak self] in
        let cellItem = TPDefaultInfoTableCellItem()
        cellItem.updater = {
            self?.updateTargetDateCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.editTargetDate()
        }
        
        return cellItem
    }()
    
    /// 重复
    lazy var repeatRuleCellItem: TPImageInfoTableCellItem = {  [weak self] in
        let cellItem = TPImageInfoTableCellItem()
        cellItem.autoResizable = true
        cellItem.minimumHeight = Config.defaultCellHeight
        cellItem.subtitleConfig.numberOfLines = 0
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Repeat")
        cellItem.updater = {
            guard let self = self else { return }
//            self.frequencyCellItem.title = self.timePlan.title
//            self.frequencyCellItem.subtitle = self.timePlan.title
        }
    
        cellItem.didSelectHandler = {
            self?.editRepeatRule()
        }
        
        return cellItem
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
    
    private func updateTargetDateCellItem() {
        targetDateCellItem.title = editingEvent.date.displayText
    }
    
    private func editTargetDate() {
        let vc = CountdownDatePickerViewController(countdownDate: editingEvent.date)
        vc.didPickDate = { date in
            self.editingEvent.date = date
            self.adapter.reloadCell(forItem: self.targetDateCellItem, with: .none)
        }
        
        vc.popoverShow()
    }
  
    // MARK: - Edit
//    private func editRepeatRule() {
//        guard let cell = adapter.cellForItem(repeatRuleCellItem) else {
//            return
//        }
//
//        let menuVC = CountdownRepeatMenuController(date: editingEvent.date)
//        menuVC.showMenu(from: cell,
//                        sourceRect: cell.bounds,
//                        isCovered: false)
//    }
    
    private func editRepeatRule() {
        let editVC = CountdownRepeatEditViewController(repeatRule: nil, date: editingEvent.date)
        editVC.didEndEditing = { repeatRule in

        }

        let navController = UINavigationController(rootViewController: editVC)
        navController.popoverShow()
    }
    
}
