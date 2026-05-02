//
//  TodoHomeHeaderTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/23.
//

import Foundation

class TodoHomeHeaderTableCellItem: TPImageInfoTableCellItem {
    
    var isExpanded: Bool = true
    
    override init() {
        super.init()
        self.registerClass = TodoHomeHeaderTableCell.self
        self.height = 55.0
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 16.0)
        self.rightViewSize = CGSize(width: 18.0, height: 18.0)
    }
}

protocol TodoHomeHeaderTableCellDelegate: AnyObject {
    
    /// 点击添加
    func todoHomeHeaderTableCellDidClickAdd(_ cell: TodoHomeHeaderTableCell)
    
}

class TodoHomeHeaderTableCell: TPImageInfoTableCell {

    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? TodoHomeHeaderTableCellItem else {
                return
            }

            self.isExpanded = cellItem.isExpanded
        }
    }
    
    /// 是否已展开
    var isExpanded: Bool {
        get {
            return expandButton.isExpanded
        }
        
        set {
            setExpanded(newValue, animated: false)
        }
    }
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.image = resGetImage("todo_home_expand_18")
        button.imageConfig.color = .systemGray3
        return button
    }()

    /// 添加按钮
    lazy var addButton: TPDefaultButton = {
        let button = TPDefaultButton.addButton()
        button.addTarget(self, action: #selector(clickAdd(_:)), for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentPadding = UIEdgeInsets(left: 16.0, right: 16.0)
        
        self.infoView.rightAccessoryView = self.addButton
        self.infoView.rightAccessorySize = .mini
        self.infoView.rightAccessoryMargins = UIEdgeInsets(right: 8.0)
        
        self.expandButton.isUserInteractionEnabled = false
        self.rightView = expandButton
        self.rightViewSize = CGSize(width: 18.0, height: 18.0)
        self.setExpanded(isExpanded, animated: false)
    }

    @objc private func clickAdd(_ button: UIButton) {
        if let delegate = delegate as? TodoHomeHeaderTableCellDelegate {
            delegate.todoHomeHeaderTableCellDidClickAdd(self)
        }
    }
    
    func toggleExpand() {
        setExpanded(!isExpanded, animated: true)
    }
    
    // MARK: - Public Methods
    /// 动画更新展开状态
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard expandButton.isExpanded != isExpanded else {
            return
        }
        
        expandButton.setExpanded(isExpanded, animated: animated)
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}
