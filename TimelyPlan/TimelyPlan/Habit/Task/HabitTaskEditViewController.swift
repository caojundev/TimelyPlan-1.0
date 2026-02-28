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
    
    /// 编辑任务
    var editingTask: HabitEditingTask

    /// 结束编辑回调
    var didEndEditing: ((HabitEditingTask) -> Void)?
    
    /// 编辑类型
    private var editType: EditType = .create
    
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
        cellItem.colors = UIColor.habitTaskColors
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
        sectionController.headerItem.height = 50.0
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.goal = self.editingTask.goal
        sectionController.goalDidChange = {[weak self] goal in
            self?.editingTask.goal = goal
        }
        
        return sectionController
    }()
    
    // MARK: - 日期和频率
    /// 日期范围
    lazy var dateFrequencySectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.title = resGetString("Date And Frequency")
        sectionController.headerItem.height = 50.0
        sectionController.headerItem.padding = sectionHeaderPadding
        sectionController.cellItems = [frequencyCellItem]
        return sectionController
    }()
    
    /// 频率
    lazy var frequencyCellItem: TPDefaultInfoTableCellItem = {  [weak self] in
        let cellItem = TPDefaultInfoTableCellItem(autoResizable: true)
        cellItem.minimumHeight = 55.0
        cellItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
        cellItem.subtitleConfig.numberOfLines = 0
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Frequency")
        cellItem.updater = {
            guard let self = self else { return }
            let timePlan = self.editingTask.timePlan
            self.frequencyCellItem.title = timePlan.title
            self.frequencyCellItem.subtitle = timePlan.subtitle
        }
    
        cellItem.didSelectHandler = {
            self?.editFrequency()
        }
        
        return cellItem
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
                                  goalSectionController,
                                  dateFrequencySectionController,
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
    
    func editFrequency() {
        let vc = HabitTimePlanEditViewController(timePlan: editingTask.timePlan)
        vc.didEndEditing = { timePlan in
            self.editingTask.timePlan = timePlan
            self.adapter.reloadCell(forItem: self.frequencyCellItem, with: .none)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.show()
    }
}

/*
class HabitTaskEditViewController: BaseTaskEditViewController {

 /// 日期范围
//    lazy var dateRangeCellItem: DateRangeEditCellItem = { [weak self] in
//        let cellItem = DateRangeEditCellItem()
//        cellItem.updater = {
//            guard let self = self else {
//                return
//            }
//
//            self.dateRangeCellItem.dateRange = self.dateRange
//        }
//
//        cellItem.didEndEditing = { dateRange in
//            self?.didEndEditingDateRange(dateRange)
//        }
//
//        return cellItem
//    }()
//
//    func didEndEditingDateRange(_ dateRange: DateRange) {
//        self.dateRange = dateRange
//    }
//

    /// 提醒
    lazy var reminderSectionItem: HabitReminderSectionItem = {
        let sectionItem = HabitReminderSectionItem()
        sectionItem.shouldRemind = shouldRemind
        sectionItem.reminder = reminder ?? Reminder()
        sectionItem.shouldRemindDidChange = { [weak self] shouldRemind in
            self?.shouldRemind = shouldRemind
        }
        
        sectionItem.reminderDidChange = { [weak self] reminder in
            self?.reminder = reminder
        }
        
        return sectionItem
    }()
}
 */
