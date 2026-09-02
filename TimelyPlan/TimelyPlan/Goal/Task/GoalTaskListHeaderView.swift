//
//  GoalTaskListHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

protocol GoalTaskListHeaderViewDelegate: AnyObject {
    
    /// 分组头视图是否展开
    func isExpandedGoalTaskListHeaderView(_ headerView: GoalTaskListHeaderView) -> Bool
    
    /// 是否可以切换展开状态
    func goalTaskListHeaderView(_ headerView: GoalTaskListHeaderView, canToggleExpandStateTo isExpanded: Bool) -> Bool
    
    /// 切换展开 / 收起状态
    func goalTaskListHeaderView(_ headerView: GoalTaskListHeaderView, didToggleExpand isExpanded: Bool)
}

/// 目标任务列表区块头视图
class GoalTaskListHeaderView: UICollectionReusableView {
    
    /// 代理对象
    weak var delegate: GoalTaskListHeaderViewDelegate?
    
    /// 所在区块索引
    var section: Int = -1
    
    /// 分组内任务数目
    var count: Int = 0 {
        didSet {
            if count != oldValue {
                countLabel.text = "\(count)"
                setNeedsLayout()
            }
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
    
    /// 任务数目标签
    private(set) lazy var countLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.textColor = resGetColor(.title)
        label.text = "\(count)"
        return label
    }()
    
    /// 分组标题
    var title: String? {
        get {
            return expandButton.title as? String
        }
        
        set {
            expandButton.title = newValue
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContentSubviews() {
        expandButton.isExpanded = isExpanded
        addSubview(expandButton)
        addSubview(countLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = layoutFrame()
        
        countLabel.layer.backgroundColor = expandButton.normalBackgroundColor?.cgColor
        countLabel.layer.cornerRadius = 8.0
        countLabel.sizeToFit()
        countLabel.centerY = layoutFrame.midY
        countLabel.right = layoutFrame.maxX
        
        expandButton.sizeToFit()
        expandButton.left = layoutFrame.minX
        expandButton.centerY = layoutFrame.midY
        
        let expandButtonMaxWidth = countLabel.left - layoutFrame.minX - 5.0
        if expandButton.width > expandButtonMaxWidth {
            expandButton.width = expandButtonMaxWidth
        }
    }
    
    // MARK: - Event Response
    /// 点击展开或收起按钮
    @objc func clickExpand(_ button: UIButton) {
        guard let delegate = delegate else {
            return
        }
        
        let isExpanded = !self.isExpanded
        guard delegate.goalTaskListHeaderView(self, canToggleExpandStateTo: isExpanded) else {
            return
        }
        
        setExpanded(isExpanded, animated: true)
        delegate.goalTaskListHeaderView(self, didToggleExpand: isExpanded)
    }
    
    // MARK: - Public Methods
    /// 更新展开状态
    func updateExpanded(animated: Bool) {
        guard let delegate = delegate else {
            return
        }
        
        let isExpanded = delegate.isExpandedGoalTaskListHeaderView(self)
        setExpanded(isExpanded, animated: animated)
    }
    
    /// 设置展开状态
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard self.isExpanded != isExpanded else {
            return
        }
        
        self.isExpanded = isExpanded
        expandButton.isExpanded = isExpanded
        if animated {
            animateLayout(withDuration: 0.25)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}
