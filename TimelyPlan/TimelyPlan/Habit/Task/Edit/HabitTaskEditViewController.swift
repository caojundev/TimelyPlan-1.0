//
//  HabitTaskEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/29.
//

import Foundation
import UIKit

class HabitTaskEditViewController: TPTableSectionsViewController {
    
    private let sectionHeaderPadding = UIEdgeInsets(top: 15.0,
                                                    left: 0.0,
                                                    bottom: 0.0,
                                                    right: 16.0)
    private let sectionHeaderHeight = 50.0
    
    /// 编辑任务
    var editingTask: HabitEditingTask

    /// 结束编辑回调
    var didEndEditing: ((HabitEditingTask) -> Void)?
    
    /// 编辑类型
    private var editType: EditType = .create
    
    let defaultCellHeight = 55.0
    
    // MARK: - 图标和名称
    lazy var iconNameSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.cellItems = [iconNameCellItem]
        return sectionController
    }()

    lazy var iconNameCellItem: HabitIconNameTableCellItem = { [weak self] in
        let cellItem = HabitIconNameTableCellItem()
        cellItem.placeholder = resGetString("Fill in the habit name")
        cellItem.clearButtonMode = .never
        cellItem.textAlignment = .center 
        cellItem.updater = {
            self?.updateIconNameCellItem()
        }

        cellItem.didSelectIcon = { icon in
            self?.didSelectIcon(icon)
        }

        cellItem.editingChanged = { textField in
            let name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.nameEditingChanged(name)
        }

        cellItem.didEndEditing = { textField in
            let name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.didEndEditingName(name)
        }

        return cellItem
    }()

    /// 颜色
    lazy var colorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.cellItems = [colorSelectCellItem]
        return sectionController
    }()

    lazy var colorSelectCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = HabitConstant.taskColors
        cellItem.updater = {
            self?.colorSelectCellItem.selectedColor = self?.editingTask.color
        }
        
        cellItem.didSelectColor = { color in
            self?.editingTask.color = color
        }
        
        return cellItem
    }()
   
    /// 目标
    lazy var goalSectionController: HabitGoalSectionController = {
        let sectionController = HabitGoalSectionController()
        sectionController.headerItem.height = sectionHeaderHeight
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.goal = self.editingTask.goal
        sectionController.goalDidChange = {[weak self] goal in
            self?.editingTask.goal = goal
        }
        
        return sectionController
    }()
    
    /// 日期频率
    lazy var dateFrequencySectionController: DateFrequencySectionController = {
        let sectionController = DateFrequencySectionController()
        sectionController.headerItem.title = resGetString("Date And Frequency")
        sectionController.headerItem.height = sectionHeaderHeight
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.dateRange = self.editingTask.dateRange
        sectionController.timePlan = self.editingTask.timePlan
        sectionController.dateRangeDidChange = { [weak self] dateRange in
            self?.editingTask.dateRange = dateRange
        }
        
        sectionController.timePlanDidChange = { [weak self] timePlan in
            self?.editingTask.timePlan = timePlan
        }
        
        return sectionController
    }()
    
    /// 时间
    lazy var timeSectionController: HabitTimeEditSectionController = {
        let sectionController = HabitTimeEditSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.timeOption = self.editingTask.timeOption
        sectionController.onTimeOptionChanged = { [weak self] timeOption in
            self?.editingTask.timeOption = timeOption
        }

        return sectionController
    }()
    
    /// 提醒
    lazy var reminderSectionController: HabitReminderEditSectionController = {
        let sectionController = HabitReminderEditSectionController()
        sectionController.headerItem.height = sectionHeaderHeight
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.shouldRemind = editingTask.shouldRemind
        if let reminder = editingTask.reminder {
            sectionController.reminder = reminder
        }

        sectionController.shouldRemindDidChange = { [weak self] shouldRemind in
            self?.editingTask.shouldRemind = shouldRemind
        }
        
        sectionController.reminderDidChange = { [weak self] reminder in
            self?.editingTask.reminder = reminder
        }
        
        return sectionController
    }()
    
    /// 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.noteCellItem.updater = {
            self?.noteSectionController.note = self?.editingTask.note
        }

        sectionController.noteEditingChanged = { note in
            self?.editingTask.note = note
        }

        return sectionController
    }()
    
    /// 我的一天
    lazy var myDaySectionController: MyDayEditSectionController = { [weak self] in
        let sectionController = MyDayEditSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.myDayCellItem.imageName = nil
        return sectionController
    }()
    
    init(task: HabitEditingTask? = nil) {
        if let task = task {
            self.editingTask = task
            self.editType = .modify
        } else {
            self.editingTask = HabitEditingTask()
        }
        
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
                                  myDaySectionController,
                                  goalSectionController,
                                  dateFrequencySectionController,
                                  timeSectionController,
                                  reminderSectionController,
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
        /// 当前目标名称为空，开始编辑名称
        beginNameEditingIfNeeded()
        /// 将选中颜色滚动到可视位置
        scrollSelectedColorToVisible()
    }
    
    // MARK: - UI Update
    func updateTitle() {
        if editType == .create {
            self.title = resGetString("New Habit")
        } else {
            self.title = resGetString("Edit Habit")
        }
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        doneBarButtonItem.isEnabled = isDoneButtonItemEnabled()
    }
    
    func isDoneButtonItemEnabled() -> Bool {
        return !isEmptyName
    }
        
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = editingTask.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
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
        if let cell = adapter.cellForItem(iconNameCellItem) as? TPTextFieldTableCell {
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
        self.didEndEditing?(self.editingTask)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - 图标和名称
    /// 更新名称和图标条目数据
    func updateIconNameCellItem() {
        iconNameCellItem.icon = editingTask.icon
        iconNameCellItem.text = editingTask.name
    }
    
    ///
    func didSelectIcon(_ icon: TPIcon) {
        editingTask.icon = icon
    }
    
    /// 名称编辑改变
    func nameEditingChanged(_ name: String?) {
        self.editingTask.name = name
        updateDoneButtonEnabled()
    }
    
    func didEndEditingName(_ name: String?) {
        
    }

}
