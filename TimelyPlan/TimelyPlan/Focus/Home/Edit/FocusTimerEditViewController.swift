//
//  FocusTimerEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/25.
//

import Foundation
import UIKit

class FocusTimerEditViewController: TPTableSectionsViewController {
    
    /// 结束编辑
    var didEndEditing: ((FocusEditingTimer) -> Void)?
    
    /// 编辑类型
    var editType: EditType = .create
    
    /// 当前编辑计时器
    var editingTimer: FocusEditingTimer

    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [nameCellItem, colorSelectCellItem]
        return sectionController
    }()
    
    /// 名称单元格条目
    lazy var nameCellItem: TPTextFieldTableCellItem = { [weak self] in
        let cellItem = TPTextFieldTableCellItem()
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_BODY_FONT
        cellItem.selectAllAtBeginning = true
        cellItem.placeholder = resGetString("Enter timer name")
        cellItem.updater = {
            self?.nameCellItem.text = self?.editingTimer.name
        }
        
        cellItem.editingChanged = { textField in
            self?.editingTimer.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }
        
        return cellItem
    }()

    /// 颜色选择
    lazy var colorSelectCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = UIColor.focusTimerColors
        cellItem.updater = {
            self?.colorSelectCellItem.selectedColor = self?.editingTimer.color
        }
        
        cellItem.didSelectColor = { color in
            self?.editingTimer.color = color
        }
        
        return cellItem
    }()

    // MARK: - 计时器
    /// 计时器模式
    lazy var timerTypeSectionController: FocusTimerTypeSectionController = {
        let sectionController = FocusTimerTypeSectionController()
        sectionController.headerItem.height = 50.0
        sectionController.didChangeTimerType = { [weak self] _ in
            UIResponder.resignCurrentFirstResponder()
            self?.editingTimer.config = self?.currentTimerConfig()
            self?.updateDoneButtonEnabled()
        }
        
        return sectionController
    }()
    
    /// 步骤配置
    lazy var steppedConfigSectionController: FocusSteppedConfigSectionController = {
        let sectionController = FocusSteppedConfigSectionController(tableView: self.tableView)
        sectionController.didChangeConfig = { [weak self] _ in
            self?.editingTimer.config = self?.currentTimerConfig()
            self?.updateDoneButtonEnabled()
        }
        
        return sectionController
    }()
    
    /// 番茄钟配置
    lazy var pomodoroConfigSectionController: FocusPomodoroConfigSectionController = {
        let sectionController = FocusPomodoroConfigSectionController()
        sectionController.didChangeConfig = { [weak self] _ in
            self?.editingTimer.config = self?.currentTimerConfig()
        }
        
        return sectionController
    }()
    
    /// 倒计时配置
    lazy var countdownConfigSectionController: FocusCountdownConfigSectionController = {
        let sectionController = FocusCountdownConfigSectionController()
        sectionController.didChangeConfig = { [weak self] _ in
            self?.editingTimer.config = self?.currentTimerConfig()
        }
        
        return sectionController
    }()
    
    /// 正计时配置
    lazy var stopwatchConfigSectionController: FocusStopwatchConfigSectionController = {
        let sectionController = FocusStopwatchConfigSectionController()
        return sectionController
    }()
    
    override var sectionControllers: [TPTableBaseSectionController]? {
        get {
            var sectionControllers: [TPTableBaseSectionController]
            sectionControllers = [nameColorSectionController,
                                  timerTypeSectionController]
            let timerType = timerTypeSectionController.timerType
            switch timerType {
            case .stepped:
                sectionControllers.append(steppedConfigSectionController)
            case .pomodoro:
                sectionControllers.append(pomodoroConfigSectionController)
            case .countdown:
                sectionControllers.append(countdownConfigSectionController)
            case .stopwatch:
                sectionControllers.append(stopwatchConfigSectionController)
            }
            
            return sectionControllers
        }
        
        set {}
    }
    
    init(timer: FocusEditingTimer? = nil) {
        if let timer = timer {
            self.editingTimer = timer
            self.editType = .modify
        } else {
            self.editingTimer = FocusEditingTimer()
        }
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.tableView.keyboardDismissMode = .onDrag
        self.updateDoneButtonEnabled()
        self.updateTitle()
        self.updateSectionControllerConfig()
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func currentTimerConfig() -> FocusTimerConfig {
        let timerType = timerTypeSectionController.timerType
        switch timerType {
        case .pomodoro:
            return FocusTimerConfig(config: pomodoroConfigSectionController.config)
        case .countdown:
            return FocusTimerConfig(config: countdownConfigSectionController.config)
        case .stopwatch:
            return FocusTimerConfig(config: stopwatchConfigSectionController.config)
        case .stepped:
            return FocusTimerConfig(config: steppedConfigSectionController.config)
        }
    }
    
    /// 更新区块配置
    func updateSectionControllerConfig() {
        let timerConfig = self.editingTimer.config ?? FocusTimerConfig()
        timerTypeSectionController.timerType = timerConfig.timerType ?? .defaultType
        if let config = timerConfig.pomodoroConfig {
            pomodoroConfigSectionController.config = config
        }
        
        if let config = timerConfig.countdownConfig {
            countdownConfigSectionController.config = config
        }
        
        if let config = timerConfig.steppedConfig {
            steppedConfigSectionController.config = config
        }
    }
    
    func updateTitle() {
        if editType == .create {
            self.title = resGetString("New Timer")
        } else {
            self.title = resGetString("Edit Timer")
        }
    }
    
    override func handleFirstAppearance() {
        /// 当前目标名称为空，开始编辑名称
        beginNameEditingIfNeeded()
        /// 将选中颜色滚动到可视位置
        scrollSelectedColorToVisible()
    }
    
    override func clickDone() {
        UIResponder.resignCurrentFirstResponder()
        self.didEndEditing?(self.editingTimer)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = self.editingTimer.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            return false
        }
        
        return true
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        doneBarButtonItem.isEnabled = isDoneButtonItemEnabled()
    }
    
    func isDoneButtonItemEnabled() -> Bool {
        guard !isEmptyName else {
            return false
        }
        
        if self.timerTypeSectionController.timerType == .stepped, !self.steppedConfigSectionController.hasStep {
            /// 步骤计时器没有步骤
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
        if let cell = adapter.cellForItem(nameCellItem) as? TPTextFieldTableCell {
            cell.textField.becomeFirstResponder()
        }
    }

    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorSelectCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
}
