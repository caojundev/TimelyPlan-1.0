//
//  RepeatMonthsEditTableViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/21.
//

import Foundation

class RepeatMonthOfYearTableCellItem: TPBaseTableCellItem {
    
    /// 选中月份回调
    var monthsOfTheYearChanged: (([Int]) -> Void)?
    
    /// 年中的月份数组（1 到 12）
    var monthsOfTheYear: [Int] = []
    
    override var height: CGFloat {
        get { return RepeatMonthOfYearSelectView.contentHeight }
        set { }
    }
    
    override init() {
        super.init()
        registerClass = RepeatMonthOfYearTableViewCell.self
        selectionStyle = .none
    }
}
    
class RepeatMonthOfYearTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? RepeatMonthOfYearTableCellItem else {
                return
            }
        
            monthsView.monthsOfTheYearChanged = cellItem.monthsOfTheYearChanged
            monthsView.monthsOfTheYear = cellItem.monthsOfTheYear
            setNeedsLayout()
        }
    }
    
    /// 月份选择视图
    var monthsView: RepeatMonthOfYearSelectView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        monthsView = RepeatMonthOfYearSelectView(frame: bounds)
        contentView.addSubview(monthsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthsView.frame = bounds
    }
    
}
