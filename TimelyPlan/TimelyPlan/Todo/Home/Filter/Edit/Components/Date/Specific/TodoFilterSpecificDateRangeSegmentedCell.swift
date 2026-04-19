//
//  TodoFilterSpecificDateRangeSegmentedCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/5.
//

import Foundation
import UIKit

class TodoFilterSpecificDateRangeSegmentedCellItem: TPBaseTableCellItem {
    
    /// 点击删除
    var didClickDelete: ((DateRangeEditType) -> Void)?
    
    /// 选中编辑类型回调
    var didSelectEditType: ((DateRangeEditType) -> Void)?
    
    /// 编辑类型
    var editType: DateRangeEditType = .start
    
    /// 日期范围
    var dateRange: DateRange?
    
    var isDeleteButtonHidden: Bool = true
    
    override init() {
        super.init()
        registerClass = TodoFilterSpecificDateRangeSegmentedCell.self
        selectionStyle = .none
        height = 80.0
    }
}

class TodoFilterSpecificDateRangeSegmentedCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TodoFilterSpecificDateRangeSegmentedCellItem else {
                return
            }
            
            segmentedView.editType = cellItem.editType
            segmentedView.dateRange = cellItem.dateRange
            segmentedView.didClickDelete = cellItem.didClickDelete
            segmentedView.didSelectEditType = cellItem.didSelectEditType
            segmentedView.isDeleteButtonHidden = cellItem.isDeleteButtonHidden
        }
    }
    
    let segmentedView = TodoFilterSpecificDateRangeSegmentedView()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(segmentedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        segmentedView.frame = bounds.inset(by: UIEdgeInsets(value: 6.0))
    }
}
