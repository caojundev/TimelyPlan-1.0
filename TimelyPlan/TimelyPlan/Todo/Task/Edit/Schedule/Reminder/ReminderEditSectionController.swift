//
//  ReminderEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/2.
//

import Foundation

class ReminderEditSectionController: TPTableItemSectionController,
                                       TPMultipleItemSelectionDelegate {
    
    /// 日期
    let eventDate: Date
    
    /// 全天
    let isAllDay: Bool
    
    /// 是否可以添加新提醒
    var canAddAlarm: (() -> Bool)?
    
    /// 点击自定义
    var didClickCustom: (() -> Void)?

    /// 选中提醒改变
    var alarmsDidChange: (([TaskAlarm]) -> Void)?
    
    /// 选中提醒数目
    var alarmsCount: Int {
        return selection.selectedCount
    }

    /// 选择控制器
    private var selection: TPMultipleItemSelection<TaskAlarm>

    /// 已计划的提醒
    lazy var alarmsCellItem: AlarmListTableCellItem = {
        let cellItem = AlarmListTableCellItem()
        cellItem.height = 60.0
        cellItem.editingEnabled = true
        return cellItem
    }()
    
    /// 预设相对提醒
    lazy var relativePresetAlarmsCellItem: AlarmPresetListTableCellItem = {
        let cellItem = AlarmPresetListTableCellItem()
        let alarmRawValues: [(daysBefore: Int, duration: Int)]
        alarmRawValues = [(0, 0),
                          (0, 5 * SECONDS_PER_MINUTE),
                          (0, 30 * SECONDS_PER_MINUTE),
                          (0, 1 * SECONDS_PER_HOUR),
                          (0, 2 * SECONDS_PER_HOUR),
                          (1, 0)]
        var alarms: [TaskAlarm] = []
        for alarmRawValue in alarmRawValues {
            let alarm = TaskAlarm(daysRelative: alarmRawValue)
            alarms.append(alarm)
        }
        
        cellItem.alarms = alarms
        return cellItem
    }()
    
    lazy var absolutePresetAlarmsCellItem: AlarmPresetListTableCellItem = {
        let cellItem = AlarmPresetListTableCellItem()
        let alarmRawValues: [(daysBefore: Int, duration: Int)]
        alarmRawValues = [(0, 9 * SECONDS_PER_HOUR),
                          (0, 13 * SECONDS_PER_HOUR),
                          (0, 18 * SECONDS_PER_HOUR),
                          (1, 9 * SECONDS_PER_HOUR),
                          (2, 9 * SECONDS_PER_HOUR),
                          (3, 9 * SECONDS_PER_HOUR)]
        
        var alarms: [TaskAlarm] = []
        for alarmRawValue in alarmRawValues {
            let alarm = TaskAlarm(daysAbsolute: alarmRawValue)
            alarms.append(alarm)
        }
        
        cellItem.alarms = alarms
        return cellItem
    }()
    
    /// 自定义提醒
    lazy var customCellItem: TPFullSizeButtonTableCellItem = { [weak self] in
        let cellItem = TPFullSizeButtonTableCellItem()
        cellItem.buttonNormalTitleColor = resGetColor(.title)
        cellItem.buttonTitle = resGetString("Custom")
        cellItem.buttonImageName = "plus_24"
        cellItem.buttonImageColor = resGetColor(.title)
        cellItem.updater = {
            let canAddAlarm = self?.canAddAlarm?() ?? false
            self?.customCellItem.isDisabled = !canAddAlarm
        }
        
        cellItem.didClickButton = { _ in
            self?.didClickCustom?()
        }
        
        return cellItem
    }()
    
    var headerTitle: String? {
        didSet {
            headerItem.title = headerTitle
        }
    }
    
    init(date: Date, isAllDay: Bool = true, alarms: [TaskAlarm]?) {
        self.eventDate = date
        self.isAllDay = isAllDay
        self.selection = TPMultipleItemSelection(items: alarms ?? [])
        
        super.init()
        let headerItem = TPDefaultInfoTableHeaderFooterItem()
        headerItem.padding = UIEdgeInsets(top: 5.0, left: 15.0, bottom: 0.0, right: 15.0)
        headerItem.height = 40.0
        headerItem.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        self.headerItem = headerItem
        self.footerItem.height = 10.0
        
        self.selection.delegate = self
        self.alarmsCellItem.selection = self.selection
        self.alarmsCellItem.eventDate = self.eventDate
        var cellItems: [TPBaseTableCellItem] = [self.alarmsCellItem]
        if isAllDay {
            self.absolutePresetAlarmsCellItem.eventDate = date
            self.absolutePresetAlarmsCellItem.selection = self.selection
            cellItems.append(self.absolutePresetAlarmsCellItem)
        } else {
            self.relativePresetAlarmsCellItem.eventDate = date
            self.relativePresetAlarmsCellItem.selection = self.selection
            cellItems.append(self.relativePresetAlarmsCellItem)
        }
        
        cellItems.append(self.customCellItem)
        self.cellItems = cellItems
    }
    
    /// 更新提醒可选状态
    func updateEnabled() {
        adapter?.reloadCell(forItem: customCellItem, with: .none)
        selection.notifyUpdaters(inserts: nil, deletes: nil)
    }
    
    func didCreateAlarm(_ alarm: TaskAlarm) {
        if !selection.isSelectedItem(alarm) {
            selection.selectItem(alarm)
        } else {
            /// 已经存在该提醒
            let cell = adapter?.cellForItem(alarmsCellItem) as? AlarmListTableViewCell
            cell?.listView.scrollToAndCommitFocusAnimation(for: alarm)
        }
    }
    
    // MARK: - TPMultipleItemSelectionDelegate
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canSelectItem item: T) -> Bool where T : Hashable {
        return canAddAlarm?() ?? false
    }

    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canDeselectItem item: T) -> Bool where T : Hashable {
        return true
    }

    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didSelectItem item: T) where T : Hashable {
        updateEnabled()
        let alarms = self.selection.selectedItems.sorted()
        alarmsDidChange?(alarms)
    }

    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didDeselectItem item: T) where T : Hashable {
        updateEnabled()
        let alarms = self.selection.selectedItems.sorted()
        alarmsDidChange?(alarms)
    }

}
