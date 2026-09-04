//
//  GoalTaskColorNameEditCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation
import UIKit

class GoalTaskColorNameEditCellItem: TPTextFieldTableCellItem {
    
    /// 当前颜色
    var color: UIColor?
    
    /// 选中颜色
    var onSelectColor: ((UIColor) -> Void)?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = GoalTaskColorNameEditCell.self
        height = 64.0
    }
}

class GoalTaskColorNameEditCell: TPTextFieldTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? GoalTaskColorNameEditCellItem else {
                return
            }
            
            colorButton.normalBackgroundColor = cellItem.color ?? .primary
            onSelectColor = cellItem.onSelectColor
        }
    }

    var color: UIColor = .primary {
        didSet {
            colorButton.normalBackgroundColor = color
            if let cellItem = cellItem as? GoalTaskColorNameEditCellItem {
                cellItem.color = color
            }
        }
    }
    
    /// 选中颜色
    var onSelectColor: ((UIColor) -> Void)?
    
    let colorSize: CGSize = .size(6)
    
    let colorButton = TPBaseButton()
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        colorButton.hitTestEdgeInsets = UIEdgeInsets(value: -15.0)
        colorButton.cornerRadius = .greatestFiniteMagnitude
        colorButton.borderWidth = 2.0
        colorButton.normalBorderColor = Color(0x888888, 0.1)
        colorButton.normalBackgroundColor = color
        colorButton.addTarget(self,
                              action: #selector(clickColor(_:)),
                              for: .touchUpInside)
        contentView.addSubview(colorButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.padding = UIEdgeInsets(horizontal: 16.0, vertical: 5.0)
        let layoutFrame = contentView.layoutFrame()
        
        colorButton.size = colorSize
        colorButton.left = layoutFrame.minX
        colorButton.alignVerticalCenter()
        
        let margin: CGFloat = 10.0
        textField.width = layoutFrame.width - colorButton.width - margin
        textField.height = layoutFrame.height
        textField.left = colorButton.right + margin
        textField.top = layoutFrame.minY
    }
    
    @objc private func clickColor(_ button: UIButton) {
        let selectView = TPColorSelectPopoverView()
        selectView.colors = GoalConfig.taskColors
        selectView.selectedColor = color
        selectView.didSelectColor = { color in
            self.color = color
            self.onSelectColor?(color)
        }
        
        selectView.reloadData()
        
        let sourceRect = CGRect(x: 0.0, y: button.height + 4.0, size: .zero)
        selectView.show(from: button,
                        sourceRect: sourceRect,
                        isCovered: false,
                        preferredPosition: .bottomRight,
                        permittedPositions: [.bottomRight],
                        animated: true)
    }
}
