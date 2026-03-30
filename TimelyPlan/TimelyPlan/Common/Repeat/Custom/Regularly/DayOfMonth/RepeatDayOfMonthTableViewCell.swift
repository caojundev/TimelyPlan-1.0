//
//  DaysOfMonthSelectTableViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/6.
//

import Foundation

class RepeatDayOfMonthTableCellItem: TPBaseTableCellItem {
    
    var days: Set<Int> = [Date().day]
    
    var didSelectDaysOfMonth: ((Set<Int>) -> Void)?
    
    override init() {
        super.init()
        registerClass = RepeatDayOfMonthTableViewCell.self
        selectionStyle = .none
        contentPadding = .zero
        height = 205.0
    }
}

class RepeatDayOfMonthTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? RepeatDayOfMonthTableCellItem else {
                return
            }
            
            selectView.selectedDaysOfMonth = cellItem.days
            selectView.didSelectDaysOfMonth = cellItem.didSelectDaysOfMonth
            selectView.reloadData()
        }
    }
    
    var selectView: RepeatDayOfMonthSelectView!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        selectView = RepeatDayOfMonthSelectView()
        contentView.addSubview(selectView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectView.frame = bounds
    }
    
}
