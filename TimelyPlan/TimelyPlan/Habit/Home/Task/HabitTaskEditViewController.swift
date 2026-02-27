//
//  HabitTaskEditViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/8/29.
//

import Foundation
import UIKit

class HabitTaskEditViewController: TPTableSectionsViewController {

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
    
    /// 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
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

    
    
    /*

    // MARK: - 日期和频率
    /// 日期范围
    lazy var dateFrequencySectionItem: TableSectionItem = {
        let sectionItem = TableSectionItem()
        sectionItem.headerItem.title = resGetString("Date And Frequency")
        sectionItem.cellItems = [dateRangeCellItem,
                                 frequencyCellItem]
        return sectionItem
    }()
    
    /// 日期范围
    lazy var dateRangeCellItem: DateRangeEditCellItem = { [weak self] in
        let cellItem = DateRangeEditCellItem()
        cellItem.updater = {
            guard let self = self else {
                return
            }
            
            self.dateRangeCellItem.dateRange = self.dateRange
        }
        
        cellItem.didEndEditing = { dateRange in
            self?.didEndEditingDateRange(dateRange)
        }
        
        return cellItem
    }()

    func didEndEditingDateRange(_ dateRange: DateRange) {
        self.dateRange = dateRange
    }
    
    /// 频率
    lazy var frequencyCellItem: SubtitleTableCellItem = {  [weak self] in
        let cellItem = SubtitleTableCellItem()
        cellItem.minimumHeight = 60.0
        cellItem.accessoryType = .disclosureIndicator
        cellItem.title = resGetString("Frequency")
        cellItem.updater = {
            self?.updateFrequencyCellItem()
        }
    
        cellItem.didSelectHandler = {
            self?.editFrequency()
        }
        
        return cellItem
    }()
    
    func updateFrequencyCellItem() {
        self.frequencyCellItem.title = timePlan.title
        self.frequencyCellItem.subtitle = timePlan.subtitle
    }
    
    func editFrequency() {
        let vc = TimePlanEditViewController(timePlan: timePlan)
        vc.didEndEditing = { timePlan in
            self.timePlan = timePlan
            self.adapter.reloadCell(forItem: self.frequencyCellItem,
                                    with: .none)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.showWithAlertStyle()
    }

    */
}

/*
class HabitTaskEditViewController: BaseTaskEditViewController {


    /// 目标
    lazy var goalSectionItem: HabitGoalSectionItem = {
        let sectionItem = HabitGoalSectionItem()
        sectionItem.goal = self.goal
        sectionItem.goalDidChange = {[weak self] goal in
            self?.goal = goal
        }
        
        return sectionItem
    }()
    
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
    
    init(task: HabitTask?) {
        self.editingTask = task?.editingTask ?? HabitEditingTask()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameIconCellItem.placeholder = resGetString("Fill in the habit name")
        self.sectionItems = [nameIconSectionItem,
                            colorSectionItem,
                            groupSectionItem,
                            goalSectionItem,
                            dateFrequencySectionItem,
                            reminderSectionItem,
                            noteSectionItem]
        self.adapter.reloadData()
    }
    
    override func updateTitle() {
        let title: String
        if editType == .create {
            title = resGetString("New Habit")
        } else {
            title = resGetString("Edit Habit")
        }
        
        self.title = title
    }
    
    override func didClickDone() {
        super.didClickDone()
        self.didEndEditing?(editingTask)
    }
    
    // MARK: - 分组处理器
    override func groupManager() -> (GroupProcessor & GroupProvider)! {
        return habit.groupManager
    }
    
}
*/
