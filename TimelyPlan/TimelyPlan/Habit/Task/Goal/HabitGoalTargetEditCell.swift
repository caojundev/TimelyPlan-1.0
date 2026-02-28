//
//  HabitGoalTargetAmountCell.swift
//  iTimeFlow
//
//  Created by caojun on 2023/4/15.
//

import Foundation
import UIKit

class HabitGoalTargetEditCellItem: TPNumberFieldTableCellItem {
    
    /// 选中单位回调
    var unitDidChange: ((String) -> Void)?
    
    /// 单位文本
    var unit: String?
    
    /// 占位单位文本
    var placeholderUnit: String = resGetString("count")
    
    override init() {
        super.init()
        registerClass = HabitGoalTargetEditCell.self
        height = 60.0
    }
}

class HabitGoalTargetEditCell: TPNumberFieldTableCell {
    private let itemMargin = 5.0
    private let itemHeight = 42.0
    private let unitMinWidth = 64.0
    
    lazy var unitView: HabitUnitButtonView = {
        let unitView = HabitUnitButtonView()
        unitView.unitDidChange = {[weak self] unit in
            self?.unitDidChange(unit)
        }

        return unitView
    }()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? HabitGoalTargetEditCellItem else {
                return
            }
            
            numberField.number = cellItem.number
            unitView.unit = cellItem.unit
            unitView.placeholderUnit = cellItem.placeholderUnit
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(unitView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = bounds.inset(by: layoutMargins)
        let titleSize = textLabel?.sizeThatFits(rect.size) ?? .zero
        let maxWidth = rect.width - titleSize.width - 2 * itemMargin
        unitView.sizeToFit()
        
        if unitView.width + Self.numberFieldSize.width > maxWidth {
            unitView.width = maxWidth - Self.numberFieldSize.width
        }
        
        if unitView.width < unitMinWidth {
            unitView.width = unitMinWidth
        }
        
        unitView.height = itemHeight
        unitView.right = rect.maxX
        unitView.alignVerticalCenter()
        unitView.backgroundColor = numberField.backgroundColor
        numberField.right = unitView.left - itemMargin
        
        /// 调整文本标签宽度
        if let textLabel = self.textLabel {
            textLabel.width = numberField.left - textLabel.left
        }
    }
    
    private func unitDidChange(_ unit: String){
        let cellItem = cellItem as! HabitGoalTargetEditCellItem
        cellItem.unit = unit
        cellItem.unitDidChange?(unit)
        setNeedsLayout()
    }
}
