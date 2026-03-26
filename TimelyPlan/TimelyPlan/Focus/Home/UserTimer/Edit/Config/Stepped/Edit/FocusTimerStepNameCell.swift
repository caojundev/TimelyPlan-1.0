//
//  FocusTimerStepNameCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/24.
//

import Foundation
import UIKit

class FocusTimerStepNameCellItem: TPTextFieldTableCellItem {
    
    /// 当前颜色
    var color: UIColor?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = FocusTimerStepNameCell.self
        height = 60.0
    }
}

class FocusTimerStepNameCell: TPTextFieldTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            updateIndicatorColor()
        }
    }

    let kIndicatorSize = CGSize(width: 6.0, height: 32.0)
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = kIndicatorSize
        view.layer.cornerRadius = kIndicatorSize.width / 2.0
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(indicatorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        let layoutFrame = contentView.layoutFrame()
        
        indicatorView.size = kIndicatorSize
        indicatorView.left = layoutFrame.minX
        indicatorView.alignVerticalCenter()
        
        let margin: CGFloat = 10.0
        textField.width = layoutFrame.width - indicatorView.width - margin
        textField.height = layoutFrame.height
        textField.left = indicatorView.right + margin
        textField.top = layoutFrame.minY
    }
    
    func updateIndicatorColor() {
        let cellItem = cellItem as! FocusTimerStepNameCellItem
        let color = cellItem.color ?? FocusTimerStep.defaultColor
        indicatorView.backgroundColor = color
    }
}
