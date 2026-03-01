//
//  HabitRecordTypeEditCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/29.
//

import Foundation
import UIKit

class HabitRecordTypeEditCellItem: TPDefaultInfoTableCellItem {
    
    /// 记录类型
    var recordType: HabitGoal.RecordType = .completeAll
    
    /// 选中记录类型回调
    var didSelectRecordType: ((HabitGoal.RecordType) -> Void)?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = HabitRecordTypeEditCell.self
        height = 66.0
    }
}

class HabitRecordTypeEditCell: TPDefaultInfoTableCell {
    
    var recordType: HabitGoal.RecordType = .completeAll
    
    var didSelectRecordType: ((HabitGoal.RecordType) -> Void)?
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! HabitRecordTypeEditCellItem
            self.recordType = cellItem.recordType
            self.didSelectRecordType = cellItem.didSelectRecordType
            self.updateButtonTitle()
        }
    }
    
    private let buttonHeight = 42.0
    
    private lazy var button: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 5)
        button.cornerRadius = .greatestFiniteMagnitude
        button.preferredTappedScale = 0.9
        button.imagePosition = .right
        button.imageConfig.shouldRenderImageWithColor = true
        button.imageConfig.color = .secondaryLabel
        button.titleConfig.textAlignment = .center
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.image = resGetImage("chevron_down_24")
        button.normalBackgroundColor = .secondarySystemFill
        button.selectedBackgroundColor = .tertiarySystemFill
        button.addTarget(self,
                         action: #selector(clickButton(_:)),
                         for: .touchUpInside)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(button)
        button.title = recordType.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = bounds.inset(by: layoutMargins)
        button.sizeToFit()
        button.height = buttonHeight
        button.right = layoutFrame.maxX
        button.alignVerticalCenter()
        infoView.width = layoutFrame.width - button.width
    }
    
    @objc func clickButton(_ button: UIButton) {
        
        /// 取消当前第一响应
        UIResponder.resignCurrentFirstResponder()
        
        /// 选择记录类型
        let menuItem = TPMenuItem.item(with: HabitGoal.RecordType.allCases,
                                       updater: { type, action in
            action.handleBeforeDismiss = true
            action.isChecked = type == self.recordType
        })
        
        let vc = TPMenuListViewController()
        vc.menuItems = [menuItem]
        vc.didSelectMenuAction = { menuAction in
            let recordType: HabitGoal.RecordType? = menuAction.actionType()
            guard let recordType = recordType, recordType != self.recordType else {
                return
            }

            self.recordType = recordType
            self.didSelectRecordType?(recordType)
            self.updateButtonTitle()
        }
        
        vc.popoverShow(from: button,
                       sourceRect: button.bounds,
                       isSourceViewCovered: true,
                       preferredPosition: .bottomLeft,
                       permittedPositions: [.bottomLeft, .topLeft],
                       animated: true,
                       completion: nil)
    }
    
    private func updateButtonTitle() {
        button.title = recordType.title
        setNeedsLayout()
    }
    
}
