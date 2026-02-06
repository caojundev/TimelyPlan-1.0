//
//  WeekdaySelectTableViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/5.
//

import Foundation
import UIKit

class RepeatDayOfWeekTableCellItem: TPBaseTableCellItem {

    var days: Set<Weekday> = []
    
    /// 选中日变化回调
    var daysChangedHandler: ((Set<Weekday>) -> Void)?
    
    override init() {
        super.init()
        registerClass = RepeatDayOfWeekTableViewCell.self
        selectionStyle = .none
        contentPadding = .zero
        height = 55.0
    }
}

class RepeatDayOfWeekTableViewCell: TPBaseTableCell, RepeatDayOfWeekSelectViewDelegate {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? RepeatDayOfWeekTableCellItem else {
                return
            }
            
            selectView.selectedWeekdays = cellItem.days
            selectView.reloadData()
        }
    }
    
    var selectView: RepeatDayOfWeekSelectView!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        selectView = RepeatDayOfWeekSelectView(frame: bounds)
        selectView.delegate = self
        contentView.addSubview(selectView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectView.frame = contentView.layoutFrame()
    }
    
    // MARK: - DaysOfWeekSelectViewDelegate
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, canSelectWeekday weekday: Weekday) -> Bool {
        return true
    }
    
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, canDeselectWeekday weekday: Weekday) -> Bool {
        if view.selectedWeekdays.count == 1 {
            return false
        }
        
        return true
    }
    
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, didDeselectWeekday weekday: Weekday) {
        didChangeWeekdays(view.selectedWeekdays)
    }
    
    func daysOfWeekSelectView(_ view: RepeatDayOfWeekSelectView, didSelectWeekday weekday: Weekday) {
        didChangeWeekdays(view.selectedWeekdays)
    }
    
    private func didChangeWeekdays(_ weekdays: Set<Weekday>) {
        guard let cellItem = cellItem as? RepeatDayOfWeekTableCellItem else {
            return
        }
        
        cellItem.days = weekdays
        cellItem.daysChangedHandler?(weekdays)
    }
}
