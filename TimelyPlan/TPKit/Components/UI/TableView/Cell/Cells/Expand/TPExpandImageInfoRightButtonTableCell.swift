//
//  TPExpandImageInfoRightButtonTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/13.
//

import Foundation

class TPExpandImageInfoRightButtonTableCellItem: TPImageInfoRightButtonTableCellItem {
    
    /// 是否已展开
    var isExpanded: Bool = true
    
    /// 切换展开状态回调
    var didToggleExpand: ((Bool) -> Void)?
    
    override init() {
        super.init()
        self.registerClass = TPExpandImageInfoRightButtonTableCell.self
        self.contentPadding = TPExpandImageInfoRightButtonTableCell.contentPadding
        self.leftViewSize = TPExpandImageInfoRightButtonTableCell.expandButtonSize
        self.leftViewMargins = TPExpandImageInfoRightButtonTableCell.expandButtonMargins
    }
}

protocol TPExpandImageInfoRightButtonTableCellDelegate: AnyObject {
    
    /// 点击展开 / 收起按钮
    func expandImageInfoTableCell(_ cell: TPExpandImageInfoRightButtonTableCell, didToggleExpand isExpanded: Bool)
}

class TPExpandImageInfoRightButtonTableCell: TPImageInfoRightButtonTableCell {

    /// 默认内容间距
    static let contentPadding = UIEdgeInsets(left: 5.0, right: 10.0)

    /// 展开按钮外间距
    static let expandButtonMargins = UIEdgeInsets(left: 5.0)
    
    /// 展开按钮尺寸 16pt
    static let expandButtonSize: CGSize = .size(4)
    
    /// 是否已展开
    var isExpanded: Bool {
        get {
            return _isExpanded
        }
        
        set {
            setExpanded(newValue, animated: false)
        }
    }

    /// 切换展开状态回调
    var didToggleExpand: ((Bool) -> Void)?
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TPExpandImageInfoRightButtonTableCellItem else {
                return
            }
            
            isExpanded = cellItem.isExpanded
            didToggleExpand = cellItem.didToggleExpand
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

    /// 是否展开
    private var _isExpanded: Bool = false
    
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
        setExpanded(!isExpanded, animated: true)
        
        if let cellItem = cellItem as? TPExpandImageInfoRightButtonTableCellItem {
            cellItem.isExpanded = isExpanded
        }
        
        /// 通知代理对象
        if let delegate = delegate as? TPExpandImageInfoRightButtonTableCellDelegate {
            delegate.expandImageInfoTableCell(self, didToggleExpand: isExpanded)
        }
        
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
    
    /// 改变展开状态通知方法，子类重写该方法进行内容更新操作
    func didChangeExpandedStatus() {
        
    }
}
