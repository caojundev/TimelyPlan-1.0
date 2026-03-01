//
//  HabitDateRangeEditCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/13.
//

import Foundation
import UIKit

class HabitDateRangeEditCellItem: TPBaseTableCellItem {
    
    /// 日期范围
    var dateRange: DateRange?
    
    var didEndEditing: ((DateRange) -> Void)?
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = HabitDateRangeEditCell.self
        self.height = 120.0
    }
}

protocol HabitDateRangeEditCellDelegate {
    /// 日期范围结束编辑
    func habitDateRangeEditCellEndEditing(_ cell: HabitDateRangeEditCell)
}

class HabitDateRangeEditCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? HabitDateRangeEditCellItem else {
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

    lazy var rangeView: HabitDateRangeView = {
        let view = HabitDateRangeView()
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
        rangeView.frame = contentView.bounds
    }
    
    private func didEndEditing(_ dateRange: DateRange) {
        if let delegate = delegate as? HabitDateRangeEditCellDelegate {
            delegate.habitDateRangeEditCellEndEditing(self)
        }
        
        if let cellItem = cellItem as? HabitDateRangeEditCellItem {
            cellItem.dateRange = dateRange
            cellItem.didEndEditing?(dateRange)
        }
    }
}
