//
//  MyDayFocusScheduleEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/2.
//

import Foundation
import UIKit

class MyDayFocusScheduleEditViewController: TPTableSectionsViewController {
    
    /// 结束编辑
    var didEndEditing: ((FocusEditingTimer) -> Void)?
    
    /// 当前编辑计时器
    var editingTimer: FocusEditingTimer

    lazy var timeEditSectionController: MyDayTimeEditSectionController = { [weak self] in
        let sectionController = MyDayTimeEditSectionController(startTime: editingTimer.startTime)
        sectionController.onStartTimeChanged = { startTime in
            self?.editingTimer.startTime = startTime
        }
        
        return sectionController
    }()
    

    init(timer: FocusEditingTimer) {
        self.editingTimer = timer
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActionsBar(actions: [doneAction])
        sectionControllers = [timeEditSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
  
    override func clickDone() {
        didEndEditing?(editingTimer)
        dismiss(animated: true, completion: nil)
    }
}


class MyDayTimeEditSectionController: TPTableItemSectionController {
    
    enum TimeType: Int, TPMenuRepresentable {
        case allDay
        case specificTime
        
        var title: String {
            switch self {
            case .allDay:
                return resGetString("All-Day")
            case .specificTime:
                return resGetString("Specific Time")
            }
        }
    }
    
    var onStartTimeChanged: ((Int64) -> Void)?
    
    private(set) var startTime: Int64
    
    /// 日期
    var date: Date? {
        if startTime >= 0 {
            return .dateWithTimeOffset(Duration(startTime))
        }
        
        return nil
    }
    
    var timeType: TimeType {
        return date == nil ? .allDay : .specificTime
    }
    
    /// 时间类型
    lazy var timeTypeCellItem: MyDayTimeTypeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = MyDayTimeTypeSegmentedMenuTableCellItem()
        cellItem.menuItems = TimeType.segmentedMenuItems()
        cellItem.updater = {
            guard let self = self else { return }
            self.timeTypeCellItem.selectedMenuTag = self.timeType.rawValue
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            let timeType: TimeType? = menuItem.actionType()
            if let timeType = timeType {
                self?.selectTimeType(timeType)
            }
        }
        
        return cellItem
    }()
    
    /// 时间选择器
    lazy var timePickerCellItem: TPTimePickerTableCellItem = { [weak self] in
        let cellItem = TPTimePickerTableCellItem()
        cellItem.height = 240.0
        cellItem.updater = {
            guard let self = self else { return }
            self.timePickerCellItem.date = self.date ?? .now
        }
        
        cellItem.didPickDate = { [weak self] date in
            self?.pickTime(date)
        }
        
        return cellItem
    }()
    
    lazy var absoluteTimePresetCellItem: TPAbsoluteTimePresetTableCellItem = {
        let cellItem = TPAbsoluteTimePresetTableCellItem()
        cellItem.height = 50.0
        cellItem.didSelectOffset = { [weak self] offset in
            self?.selectPresetAbsoluteTimeOffset(offset)
        }

        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            var items: [TPBaseTableCellItem] = [timeTypeCellItem]
            if timeType == .specificTime {
                items.append(timePickerCellItem)
                items.append(absoluteTimePresetCellItem)
            }
            
            return items
        }
        
        set {}
    }

    init(startTime: Int64) {
        self.startTime = startTime
        super.init()
    }
    
    private func selectPresetAbsoluteTimeOffset(_ offset: Duration) {
        guard startTime != offset else {
            return
        }
        
        startTime = Int64(offset)
        onStartTimeChanged?(startTime)
        if let cell = adapter?.cellForItem(timePickerCellItem) as? TPTimePickerTableCell {
            cell.reloadData(animated: true)
        }
    }

    private func selectTimeType(_ type: TimeType) {
        if type == .allDay {
            pickTime(nil)
        } else {
            pickTime(.now)
        }
        
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
    }
    
    
    /// 选中时间
    private func pickTime(_ date: Date?) {
        let offset: Int64
        if let date = date {
            offset = Int64(date.offset())
        } else {
            offset = -1
        }
        
        if startTime != offset {
            startTime = offset
            onStartTimeChanged?(startTime)
        }
    }
}

class MyDayTimeTypeSegmentedMenuTableCellItem: TPFullSizeSegmentedMenuTableCellItem {
    
    override var minimumButtonWidth: CGFloat {
        get {
            guard let cellWidth = cellWidth else {
                return 0.0
            }
            
            let count = menuItems.count
            let minWidth = ((cellWidth - menuPadding.horizontalLength) - CGFloat(count - 1) * menuMargin) / CGFloat(count)
            return minWidth
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.height = 60.0
        self.menuPadding = UIEdgeInsets(value: 8.0)
        self.menuMargin = 8.0
        self.cornerRadius = 16.0
    }
}
