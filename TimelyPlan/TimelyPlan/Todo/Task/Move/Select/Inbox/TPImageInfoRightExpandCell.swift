//
//  TPImageInfoRightExpandCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/6.
//

import Foundation
import UIKit

class TPImageInfoRightExpandCellItem: TPImageInfoTableCellItem {
    
    /// 是否已展开
    var isExpanded: Bool = true
    
    /// 切换展开状态回调
    var didToggleExpand: ((Bool) -> Void)?
    
    override init() {
        super.init()
        self.registerClass = TPImageInfoRightExpandCell.self
        self.rightViewSize = TPImageInfoRightExpandCell.expandButtonSize
        self.rightViewMargins = TPExpandDefaultInfoTableCell.expandButtonMargins
    }
    
    func toggleExpand() {
        self.isExpanded = !self.isExpanded
    }
}

protocol TPImageInfoRightExpandCellDelegate: AnyObject {
    
    func isExpandedTableCell(_ cell: TPImageInfoRightExpandCell) -> Bool
    
    func expandTableCell(_ cell: TPImageInfoRightExpandCell, canToggleExpandStateTo isExpanded: Bool) -> Bool
    
    func expandTableCell(_ cell: TPImageInfoRightExpandCell, didToggleExpand isExpanded: Bool)
}

class TPImageInfoRightExpandCell: TPImageInfoTableCell {
    
    /// 展开按钮外间距
    static let expandButtonMargins = UIEdgeInsets(left: 5.0)
    
    /// 展开按钮尺寸 16pt
    static let expandButtonSize: CGSize = .size(4)
    
    /// 是否已展开
    var isExpanded: Bool {
        return _isExpanded
    }

    /// 是否展开
    private var _isExpanded: Bool = false
    
    /// 切换展开状态回调
    var didToggleExpand: ((Bool) -> Void)?
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPImageInfoRightExpandCellItem else {
                return
            }
            
            didToggleExpand = cellItem.didToggleExpand
            updateExpanded(animated: true)
        }
    }
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.image = resGetImage("todo_home_expand_18")
        button.imageConfig.color = .systemGray3
        button.hitTestEdgeInsets = UIEdgeInsets(value: -20.0)
        button.addTarget(self, action: #selector(clickExpand(_:)), for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.rightView = expandButton
        self.rightViewSize = Self.expandButtonSize
        self.leftViewMargins = Self.expandButtonMargins
        self.setExpanded(isExpanded, animated: false)
    }
    
    // MARK: - Event Response
    /// 点击展开或收起按钮
    @objc private func clickExpand(_ button: UIButton) {
        guard let delegate = delegate as? TPImageInfoRightExpandCellDelegate else {
            return
        }
        
        let isExpanded = !self.isExpanded
        guard delegate.expandTableCell(self, canToggleExpandStateTo: isExpanded) else {
            return
        }
        
        setExpanded(isExpanded, animated: true)
        updateExpandedButton()
        delegate.expandTableCell(self, didToggleExpand: isExpanded)
        didToggleExpand?(isExpanded)
    }
    
    // MARK: - Public Methods
    /// 动画更新展开状态
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard _isExpanded != isExpanded else {
            return
        }
        
        _isExpanded = isExpanded
        expandButton.setExpanded(isExpanded, animated: animated)
        didChangeExpandedStatus()
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func isExpandButtonEnabled() -> Bool {
        guard let delegate = delegate as? TPImageInfoRightExpandCellDelegate else {
            return false
        }
        
        let isExpanded = !self.isExpanded
        return delegate.expandTableCell(self, canToggleExpandStateTo: isExpanded)
    }
    
    func updateExpandedButton() {
        if isExpandButtonEnabled() {
            self.expandButton.isEnabled = true
            self.expandButton.alpha = 1.0
        } else {
            self.expandButton.isEnabled = false
            self.expandButton.alpha = 0.4
        }
    }
    
    func updateExpanded(animated: Bool) {
        updateExpandedButton()
        
        var isExpanded: Bool = true
        if let delegate = delegate as? TPImageInfoRightExpandCellDelegate {
            /// 通过代理对象获取
            isExpanded = delegate.isExpandedTableCell(self)
        } else if let cellItem = cellItem as? TPImageInfoRightExpandCellItem {
            /// 通过单元格条目获取
            isExpanded = cellItem.isExpanded
        }
 
        setExpanded(isExpanded, animated: animated)
    }
    
    /// 改变展开状态通知方法，子类重写该方法进行内容更新操作
    func didChangeExpandedStatus() {
        updateCellItemExpandState()
    }
    
    private func updateCellItemExpandState() {
        if let cellItem = cellItem as? TPImageInfoRightExpandCellItem {
            cellItem.isExpanded = isExpanded
        }
    }
}
