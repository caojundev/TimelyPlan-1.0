//
//  TaskDateRangeEditTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/13.
//

import Foundation
import UIKit

class TaskDateRangeEditTableCellItem: TPBaseTableCellItem {
    
    /// 日期范围
    var dateRange: DateRange?
    
    var didEndEditing: ((DateRange) -> Void)?
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = TaskDateRangeEditTableCell.self
        self.height = 120.0
    }
}

protocol TaskDateRangeEditTableCellDelegate {
    /// 日期范围结束编辑
    func taskDateRangeEditTableCellEndEditing(_ cell: TaskDateRangeEditTableCell)
}

class TaskDateRangeEditTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TaskDateRangeEditTableCellItem else {
                return
            }
            
            dateRange = cellItem.dateRange ?? DateRange()
        }
    }
    
    var dateRange: DateRange {
        get {
            return rangeView.dateRange
        }

        set {
            rangeView.dateRange = newValue
        }
    }

    lazy var rangeView: TaskDateRangeView = {
        let view = TaskDateRangeView()
        view.didEndEditing = { [weak self] dateRange in
            self?.didEndEditing(dateRange)
        }
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(rangeView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rangeView.frame = bounds
    }
    
    private func didEndEditing(_ dateRange: DateRange) {
        if let delegate = delegate as? TaskDateRangeEditTableCellDelegate {
            delegate.taskDateRangeEditTableCellEndEditing(self)
        }
        
        if let cellItem = cellItem as? TaskDateRangeEditTableCellItem {
            cellItem.dateRange = dateRange
            cellItem.didEndEditing?(dateRange)
        }
    }
}
