//
//  MonthWeekdaySelectTableViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/22.
//

import Foundation

class RepeatWeekdayOfMonthTableCellItem: TPBaseTableCellItem {
    
    /// 选中月中的第几周
    var didPickDayOfTheWeek: ((RepeatDayOfWeek) -> Void)?
    
    /// 周日
    var dayOfTheWeek: RepeatDayOfWeek = RepeatDayOfWeek(dayOfTheWeek: .monday,
                                                        weekNumber: RepeatWeekNumber.first.rawValue)
    
    override init() {
        super.init()
        
        self.registerClass = RepeatWeekdayOfMonthTableViewCell.self
        self.selectionStyle = .none
        self.height = 160.0
    }
}

class RepeatWeekdayOfMonthTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? RepeatWeekdayOfMonthTableCellItem else {
                return
            }
            
            pickerView.selectDayOfTheWeek(cellItem.dayOfTheWeek, animated: true)
            setNeedsLayout()
        }
    }
    
    /// 月份选择视图
    var pickerView: RepeatWeekdayOfMonthPickerView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        pickerView = RepeatWeekdayOfMonthPickerView(frame: bounds)
        pickerView.didPickDayOfTheWeek = { [weak self] dayOfTheWeek in
            self?.pickDayOfTheWeek(dayOfTheWeek)
        }
        
        contentView.addSubview(pickerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pickerView.frame = bounds
    }
    
    func pickDayOfTheWeek(_ dayOfTheWeek:RepeatDayOfWeek) {
        guard let cellItem = cellItem as? RepeatWeekdayOfMonthTableCellItem else {
            return
        }
        
        cellItem.dayOfTheWeek = dayOfTheWeek
        cellItem.didPickDayOfTheWeek?(dayOfTheWeek)
    }
    
}
