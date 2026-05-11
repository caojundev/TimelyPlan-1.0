//
//  TPExpandDefaultInfoTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/7.
//

import Foundation
import UIKit

class TPExpandDefaultInfoTableCellItem: TPDefaultInfoTableCellItem {
    
    /// 是否已展开
    var isExpanded: Bool = true
    
    /// 切换展开状态回调
    var didToggleExpand: ((Bool) -> Void)?
    
    override init() {
        super.init()
        self.registerClass = TPExpandDefaultInfoTableCell.self
        self.contentPadding = TPExpandDefaultInfoTableCell.contentPadding
        self.leftViewSize = TPExpandDefaultInfoTableCell.expandButtonSize
        self.leftViewMargins = TPExpandDefaultInfoTableCell.expandButtonMargins
    }
    
    func toggleExpand() {
        self.isExpanded = !self.isExpanded
    }
}

protocol TPExpandDefaultInfoTableCellDelegate: AnyObject {
    
    func isExpandedTableCell(_ cell: TPExpandDefaultInfoTableCell) -> Bool
    
    func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, canToggleExpandStateTo isExpanded: Bool) -> Bool
    
    func expandTableCell(_ cell: TPExpandDefaultInfoTableCell, didToggleExpand isExpanded: Bool)
}

class TPExpandDefaultInfoTableCell: TPDefaultInfoTableCell {

    /// 默认内容间距
    static let contentPadding = UIEdgeInsets(left: 5.0, right: 10.0)

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
            guard let cellItem = cellItem as? TPExpandDefaultInfoTableCellItem else {
                return
            }
            
            didToggleExpand = cellItem.didToggleExpand
            setExpanded(cellItem.isExpanded, animated: false)
        }
    }
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.hitTestEdgeInsets = UIEdgeInsets(value: -20.0)
        button.addTarget(self, action: #selector(clickExpand(_:)), for: .touchUpInside)
        return button
    }()

    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentPadding = Self.contentPadding
        self.leftView = self.expandButton
        self.leftViewSize = Self.expandButtonSize
        self.leftViewMargins = Self.expandButtonMargins
        self.setExpanded(isExpanded, animated: false)
    }
    
    // MARK: - Event Response
    /// 点击展开或收起按钮
    @objc private func clickExpand(_ button: UIButton) {
        guard let delegate = delegate as? TPExpandDefaultInfoTableCellDelegate else {
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
        guard let delegate = delegate as? TPExpandDefaultInfoTableCellDelegate else {
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
        guard let delegate = delegate as? TPExpandDefaultInfoTableCellDelegate else {
            return
        }
        
        let isExpanded = delegate.isExpandedTableCell(self)
        setExpanded(isExpanded, animated: animated)
        updateExpandedButton()
    }
    
    /// 改变展开状态通知方法，子类重写该方法进行内容更新操作
    func didChangeExpandedStatus() {
        updateCellItemExpandState()
    }
    
    private func updateCellItemExpandState() {
        if let cellItem = cellItem as? TPExpandDefaultInfoTableCellItem {
            cellItem.isExpanded = isExpanded
        }
    }
    
}
