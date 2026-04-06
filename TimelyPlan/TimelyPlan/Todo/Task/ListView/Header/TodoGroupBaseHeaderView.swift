//
//  TodoGroupBaseHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation
import UIKit

protocol TodoGroupHeaderViewDelegate: AnyObject {
    
    /// 分组头视图是否展开
    func isExpandedGroupHeaderView(_ headerView: TodoGroupBaseHeaderView) -> Bool
    
    /// 是否可以切换展开状态
    func groupHeaderView(_ headerView: TodoGroupBaseHeaderView, canToggleExpandStateTo isExpanded: Bool) -> Bool
    
    /// 切换展开 / 收起状态
    func groupHeaderView(_ headerView: TodoGroupBaseHeaderView, didToggleExpand isExpanded: Bool)
}

class TodoGroupBaseHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: TodoGroupHeaderViewDelegate?
    
    var section: Int = -1
    
    var title: String? {
        get {
            return expandButton.title as? String
        }
        
        set {
            expandButton.title = newValue
            setNeedsLayout()
        }
    }
    
    /// 是否展开
    private(set) var isExpanded: Bool = true
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = UIEdgeInsets(horizontal: 12.0, vertical: 10.0)
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.cornerRadius = 10.0
        button.normalBackgroundColor = .secondarySystemGroupedBackground
        button.selectedBackgroundColor = .secondarySystemFill
        button.addTarget(self,
                         action: #selector(clickExpand(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupContentSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubViews() {
        contentView.padding = UIEdgeInsets(horizontal: 0.0)
        contentView.addSubview(expandButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        expandButton.sizeToFit()
        expandButton.left = layoutFrame.minX
        expandButton.centerY = layoutFrame.midY
    }

    private func setExpanded(_ isExpanded: Bool, animated: Bool) {
        self.isExpanded = isExpanded
        expandButton.setExpanded(isExpanded, animated: animated)
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - Event Response
    /// 点击展开或收起按钮
    @objc func clickExpand(_ button: UIButton) {
        guard let delegate = delegate else {
            return
        }
        
        let isExpanded = !self.isExpanded
        guard delegate.groupHeaderView(self, canToggleExpandStateTo: isExpanded) else {
            return
        }
        
        setExpanded(isExpanded, animated: true)
        updateExpandedButton()
        delegate.groupHeaderView(self, didToggleExpand: isExpanded)
    }
    
    // MARK: - Public Methods
    func updateExpanded(animated: Bool) {
        guard let delegate = delegate else {
            return
        }
        
        let isExpanded = delegate.isExpandedGroupHeaderView(self)
        setExpanded(isExpanded, animated: animated)
        updateExpandedButton()
    }
    
    func updateExpandedButton() {
        guard let delegate = delegate else {
            return
        }
        
        let isExpanded = !self.isExpanded
        if delegate.groupHeaderView(self, canToggleExpandStateTo: isExpanded) {
            self.expandButton.isEnabled = true
            self.expandButton.alpha = 1.0
        } else {
            self.expandButton.isEnabled = false
            self.expandButton.alpha = 0.4
        }
    }    
}
