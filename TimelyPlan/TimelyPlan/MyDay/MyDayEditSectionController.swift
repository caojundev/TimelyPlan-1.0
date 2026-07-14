//
//  MyDayEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/13.
//

import Foundation
import UIKit

class MyDayEditSectionController: TPTableItemSectionController {
    
    /// 添加到我的一天改变回调
    var addToMyDayValueChanged: ((Bool) -> Void)?
    
    /// 添加到我的一天
    var isAddedToMyDay: Bool = true

    let defaultCellHeight = 55.0
    
    /// 添加到我的一天
    lazy var myDayCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.imageName = "todo_task_addToMyDay_24"
        cellItem.title = resGetString("Add to My Day")
        cellItem.titleConfig.font = BOLD_SYSTEM_FONT
        cellItem.height = defaultCellHeight
        cellItem.updater = {
            guard let self = self else { return }
            self.myDayCellItem.isOn = self.isAddedToMyDay
        }

        cellItem.valueChanged = { isOn in
            self?.addToMyDayValueChanged(isOn)
        }
        
        return cellItem
    }()
    
    override init() {
        super.init()
        self.cellItems = [myDayCellItem]
    }
    
    private func addToMyDayValueChanged(_ isAddedToMyDay: Bool) {
        self.isAddedToMyDay = isAddedToMyDay
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
    }
    
}


/*
class MyDayEditSectionController: DateFrequencySectionController {
    
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
    
    /// 添加到我的一天
    var isAddedToMyDay: Bool = true

    /// 日期
    var date: Date?
    
    var timeType: TimeType {
        return date == nil ? .allDay : .specificTime
    }
    
    /// 添加到我的一天
    lazy var myDayCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.title = resGetString("Add to My Day")
        cellItem.titleConfig.font = BOLD_SYSTEM_FONT
        cellItem.height = defaultCellHeight
        cellItem.updater = {
            guard let self = self else { return }
            self.myDayCellItem.isOn = self.isAddedToMyDay
        }

        cellItem.valueChanged = { isOn in
            self?.addToMyDayValueChanged(isOn)
        }
        
        return cellItem
    }()
    
    /// 时间类型
    lazy var timeTypeCellItem: MyDayTimeTypeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = MyDayTimeTypeSegmentedMenuTableCellItem()
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
        cellItem.height = 180.0
        cellItem.updater = {
            guard let self = self else { return }
            self.timePickerCellItem.date = self.date ?? .now
        }
        
        cellItem.didPickDate = { [weak self] date in
            self?.date = date
        }
        
        return cellItem
    }()
    
    override var cellItems: [TPBaseTableCellItem]? {
        get {
            guard isAddedToMyDay else {
                return [myDayCellItem]
            }
            
            var items = [myDayCellItem,
                         dateRangeCellItem,
                         frequencyCellItem,
                         timeTypeCellItem]
            if timeType == .specificTime {
                items.append(timePickerCellItem)
            }
            
            return items
        }
        
        set {}
    }

    private func addToMyDayValueChanged(_ isAddedToMyDay: Bool) {
        self.isAddedToMyDay = isAddedToMyDay
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
    }

    private func selectTimeType(_ type: TimeType) {
        if type == .allDay {
            self.date = nil
        } else {
            self.date = .now
        }
        
        adapter?.performSectionUpdate(forSectionObject: self,
                                      rowAnimation: .fade,
                                      completion: nil)
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
        self.height = 64.0
        self.menuPadding = UIEdgeInsets(value: 8.0)
        self.menuMargin = 8.0
        self.cornerRadius = 16.0
        self.menuItems = MyDayEditSectionController.TimeType.segmentedMenuItems()
    }
}
*/
