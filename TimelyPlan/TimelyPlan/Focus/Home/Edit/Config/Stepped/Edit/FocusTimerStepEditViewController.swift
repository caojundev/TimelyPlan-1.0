//
//  FocusTimerStepEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/24.
//

import Foundation
import UIKit

class FocusTimerStepEditViewController: TPTableSectionsViewController{

    /// 结束步骤编辑
    var didEndEditing: ((FocusTimerStep) -> Void)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 步骤
    var step: FocusTimerStep
    
    init(step: FocusTimerStep? = nil) {
        self.editType = step == nil ? .create : .modify
        self.step = step ?? FocusTimerStep()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [nameCellItem, colorSelectCellItem]
        return sectionController
    }()
    
    /// 名称
    lazy var nameCellItem: FocusTimerStepNameCellItem = { [weak self] in
        let cellItem = FocusTimerStepNameCellItem()
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_BODY_FONT
        cellItem.placeholder = resGetString("Enter step name")
        cellItem.selectAllAtBeginning = true
        cellItem.updater = {
            self?.nameCellItem.text = self?.step.name
            self?.nameCellItem.color = self?.step.color
        }
        
        cellItem.editingChanged = { textField in
            self?.step.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }
        
        return cellItem
    }()
    
    /// 颜色
    lazy var colorSelectCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = FocusTimerStep.colors
        cellItem.circleSize = CGSize(width: 36.0, height: 36.0)
        cellItem.updater = {
            self?.colorSelectCellItem.selectedColor = self?.step.color
        }
        
        cellItem.didSelectColor = { color in
            self?.didSelectColor(color)
        }
        
        return cellItem
    }()

    /// 模式区块
    lazy var modeSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [modeCellItem]
        return sectionController
    }()
    
    lazy var modeCellItem: TPFullSizeSegmentedMenuTableCellItem = {
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.backgroundColor = .clear
        cellItem.cornerRadius = 16.0
        cellItem.menuItems = FocusStepMode.segmentedMenuItems(style: .iconAndTitle)
        cellItem.selectedMenuTag = self.step.mode?.index ?? 0
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let mode: FocusStepMode? = menuItem.actionType()
            if let mode = mode {
                self?.didSelectStepMode(mode)
            }
        }
        
        return cellItem
    }()

    /// 时长区块
    lazy var durationSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 10.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [descriptionCellItem,
                                       durationPickerCellItem,
                                       durationPresetCellItem]
        return sectionController
    }()

    lazy var durationPickerCellItem: TPDurationPickerTableCellItem = {
        let cellItem = TPDurationPickerTableCellItem()
        cellItem.height = 240.0
        cellItem.minimumDuration = SECONDS_PER_MINUTE
        cellItem.updater = { [weak self] in
            let duration = self?.step.duration ?? 5 * SECONDS_PER_MINUTE
            self?.durationPickerCellItem.duration = duration
        }
        
        cellItem.didPickDuration = { [weak self] duration in
            self?.didPickDuration(duration)
        }

        return cellItem
    }()
    
    lazy var durationPresetCellItem: TPDurationPresetTableCellItem = {
        let cellItem = TPDurationPresetTableCellItem()
        cellItem.presetMinutes = [5, 15, 25, 30, 45, 60, 90, 120, 240]
        cellItem.height = 60.0
        cellItem.didSelectMinute = { [weak self] minutes in
            self?.didSelectPresetDuration(minutes * SECONDS_PER_MINUTE)
        }

        return cellItem
    }()
    
    /// 描述信息单元格
    lazy var descriptionCellItem: TPDescriptionTableCellItem = {
        let cellItem = TPDescriptionTableCellItem()
        cellItem.selectionStyle = .none
        cellItem.updater = { [weak self] in
            guard let self = self else { return }
            self.descriptionCellItem.attributedText = self.attributedDescription
        }
        
        return cellItem
    }()
    
    private var attributedDescription: ASAttributedString {
        let mode = step.mode ?? .focus
        let duration = step.duration ?? FocusTimerStep.defaultDuration
        let format: String
        if mode == .focus {
            format = resGetString("Focus for %@, the focus duration will be added to the record.")
        } else {
            format = resGetString("Rest for %@, the rest duration will not be added to the record.")
        }
    
        let info: ASAttributedString = .string(format: format,
                                               stringParameters: [duration.localizedTitle])
        return info
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if editType == .create {
            self.title = resGetString("New Step")
        } else {
            self.title = resGetString("Edit Step")
        }
        
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        self.tableView.keyboardDismissMode = .onDrag
        self.sectionControllers = [nameColorSectionController,
                                   modeSectionController,
                                   durationSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.reloadData()
        self.updateDoneButtonEnabled()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func handleFirstAppearance() {
        self.beginNameEditingIfNeeded()
        self.scrollSelectedColorToVisible()
    }
    
    override func clickDone() {
        self.didEndEditing?(step)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 名称
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = step.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            return false
        }
        
        return true
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        self.doneBarButtonItem.isEnabled = !isEmptyName
    }
    
    /// 当前名称为空时编辑名称
    func beginNameEditingIfNeeded() {
        if isEmptyName {
            beginNameEditing()
        }
    }
    
    /// 开始名称编辑
    func beginNameEditing() {
        if let cell = adapter.cellForItem(nameCellItem) as? FocusTimerStepNameCell {
            cell.textField.becomeFirstResponder()
        }
    }

    /// 名称编辑改变
    func nameEditingChanged(_ name: String?) {
        self.step.name = name
        self.updateDoneButtonEnabled()
    }
    
    // MARK: - 颜色
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorSelectCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
    
    func didSelectColor(_ color: UIColor) {
        self.step.color = color
        
        /// 更新名称单元格颜色
        self.nameCellItem.color = color
        if let cell = adapter.cellForItem(nameCellItem) as? FocusTimerStepNameCell {
            cell.updateIndicatorColor()
        }
    }
    
    // MARK: - 选中模式
    private func didSelectStepMode(_ mode: FocusStepMode) {
        self.step.mode = mode
        self.adapter.reloadCell(forItem: descriptionCellItem, with: .none)
    }
    
    // MARK: - Select
    func didPickDuration(_ duration: Duration) {
        self.step.duration = duration
        self.adapter.reloadCell(forItem: descriptionCellItem, with: .none)
    }
    
    func didSelectPresetDuration(_ duration: Duration) {
        self.didPickDuration(duration)
        if let cell = adapter.cellForItem(durationPickerCellItem) as? TPDurationPickerTableCell {
            cell.reloadData(animated: true)
        }
    }
}
