//
//  HabitTimeEditTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/2.
//

import Foundation
import UIKit

class HabitTimeEditTableCellItem: TPBaseTableCellItem {
    
    /// 选中时间回调
    var didSelectTimeOption: ((HabitTimeOption) -> Void)?
    
    var selectedOption: HabitTimeOption = .anytime
    
    override init() {
        super.init()
        self.selectionStyle = .none
        self.registerClass = HabitTimeEditTableCell.self
        self.height = 120.0
    }
}

class HabitTimeEditTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? HabitTimeEditTableCellItem else {
                return
            }
            
            selectView.selectedOption = cellItem.selectedOption
            selectView.didSelectTimeOption = cellItem.didSelectTimeOption
        }
    }
    
    lazy var selectView: HabitTimeSelectView = {
        let view = HabitTimeSelectView()
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(selectView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectView.frame = bounds
    }
}
