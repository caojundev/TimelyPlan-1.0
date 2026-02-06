//
//  TPCalendarTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/9.
//

import Foundation
import UIKit

class TPCalendarTableCellItem: TPBaseTableCellItem {
        
    /// 月视图代理对象
    weak var monthViewDelegate: TPCalendarMonthViewDelegate?
    
    /// 可见日期
    var visibleDateComponents = Date().yearMonthDayComponents
    
    /// 日期选择管理器
    var selection: TPCalendarDateSelection = TPCalendarSingleDateSelection()

    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TPCalendarTableCell.self
        self.height = TPCalendarTableCell.defaultHeight
    }
}

class TPCalendarTableCell: TPBaseTableCell {
    
    /// 默认高度
    static let defaultHeight = 400.0

    /// 月视图代理对象
    weak var monthViewDelegate: TPCalendarMonthViewDelegate?
    
    /// 可见日期
    lazy var visibleDateComponents: DateComponents = {
        return Date().yearMonthComponents
    }()
    
    /// 日期选择管理器
    var selection: TPCalendarDateSelection?
    
    /// 日历视图
    private(set) var calendarView: TPCalendarView!
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            reloadData(animated: false)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        calendarView = TPCalendarView(frame: contentView.bounds)
        calendarView.visibleDateDidChange = { [weak self] dateComponents in
            self?.visibleDateDidChange(dateComponents)
        }
        
        contentView.addSubview(calendarView)
        calendarView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        calendarView.frame = contentView.bounds
        CATransaction.commit()
    }
    
    func visibleDateDidChange(_ dateComponents: DateComponents) {
        guard let cellItem = cellItem as? TPCalendarTableCellItem else {
            return
        }
        
        cellItem.visibleDateComponents = dateComponents
    }
    
    public func reloadData(animated: Bool) {
        if let cellItem = cellItem as? TPCalendarTableCellItem {
            monthViewDelegate = cellItem.monthViewDelegate
            selection = cellItem.selection
            visibleDateComponents = cellItem.visibleDateComponents
        }

        calendarView.monthViewDelegate = monthViewDelegate
        calendarView.selection = selection
        calendarView.setVisibleDateComponents(visibleDateComponents, animated: animated)
    }
}
