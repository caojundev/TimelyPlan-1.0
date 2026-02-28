//
//  HabitGoalTargetAmountCell.swift
//  iTimeFlow
//
//  Created by caojun on 2023/4/15.
//

import Foundation
import UIKit

class HabitGoalTargetAmountCellItem: TPNumberFieldTableCellItem {
    
    /// 选中单位回调
    var unitDidChange: ((String) -> Void)?
    
    /// 单位文本
    var unit: String?
    
    /// 占位单位文本
    var placeholderUnit: String = resGetString("count")
    
    override init() {
        super.init()
        registerClass = HabitGoalEditCell.self
        height = 60.0
    }
}

class HabitGoalEditCell: TPNumberFieldTableCell {
    let kItemMargin = 5.0
    let kItemHeight = 42.0
    let kUnitMinWidth = 64.0
    
//    lazy var unitView: UnitButtonView = {
//        let unitView = UnitButtonView()
//        unitView.unitDidChange = {[weak self] unit in
//            self?.unitDidChange(unit)
//        }
//
//        return unitView
//    }()
    
    lazy var unitView: UIView = {
        return UIView()
    }()
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? HabitGoalTargetAmountCellItem else {
                return
            }
            
//            numberField.number = cellItem.number
//            unitView.unit = cellItem.unit
//            unitView.placeholderUnit = cellItem.placeholderUnit
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
        let maxWidth = rect.width - titleSize.width - 2 * kItemMargin
        unitView.sizeToFit()
        
        if unitView.width + Self.numberFieldSize.width > maxWidth {
            unitView.width = maxWidth - Self.numberFieldSize.width
        }
        
        if unitView.width < kUnitMinWidth {
            unitView.width = kUnitMinWidth
        }
        
        unitView.height = kItemHeight
        unitView.right = rect.maxX
        unitView.alignVerticalCenter()
        unitView.backgroundColor = numberField.backgroundColor
        
        numberField.right = unitView.left - kItemMargin
        
        /// 调整文本标签宽度
        if let textLabel = self.textLabel {
            textLabel.width = numberField.left - textLabel.left
        }
    }
    
    private func unitDidChange(_ unit: String){
        animateLayout(withDuration: 0.2)
        guard let cellItem = cellItem as? HabitGoalTargetAmountCellItem else {
            return
        }
        
        cellItem.unit = unit
        cellItem.unitDidChange?(unit)
    }
}
