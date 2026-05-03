//
//  HabitTaskListGroupHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/4.
//

import Foundation
import UIKit

protocol HabitTaskListGroupHeaderViewDelegate: TPCollectionHeaderFooterViewDelegate {
    
    /// 是否为展开状态
    func isExpandedGroupHeaderView(_ headerView: HabitTaskListGroupHeaderView) -> Bool
    
    /// 切换展开状态
    func groupHeaderView(_ headerView: HabitTaskListGroupHeaderView, didToggleExpand isExpanded: Bool)
}

class HabitTaskListGroupHeaderView: TPCollectionHeaderFooterView {
    
    var group: HabitTaskGroup? {
        didSet {
            updateInfo()
        }
    }
    
    /// 值标签
    private(set) lazy var valueLabel: TPLabel = {
        let label = TPLabel()
        label.edgeInsets = UIEdgeInsets(horizontal: 4.0)
        label.textAlignment = .center
        label.font = BOLD_SMALL_SYSTEM_FONT
        label.lineBreakMode = .byTruncatingTail
        label.textColor = resGetColor(.title)
        return label
    }()

    /// 展开按钮尺寸 16pt
    let expandButtonSize: CGSize = .size(4)
    
    /// 展开按钮
    private(set) lazy var expandButton: TPChevronExpandButton = {
        let button = TPChevronExpandButton()
        button.padding = .zero
        button.image = resGetImage("todo_home_expand_18")
        button.hitTestEdgeInsets = UIEdgeInsets(value: -20.0)
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickExpand), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.infoView.imageConfig.margins = UIEdgeInsets(right: 8.0)
        self.infoView.rightAccessoryView = self.valueLabel
        self.infoView.rightAccessoryMargins = UIEdgeInsets(right: 8.0)
        self.contentView.addSubview(self.expandButton)
        
        // 添加单击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        self.expandButton.size = expandButtonSize
        self.expandButton.right = layoutFrame.maxX
        self.expandButton.centerY = layoutFrame.midY
    
        let valueSize = valueLabel.sizeThatFits(.unlimited)
        self.infoView.rightAccessorySize = valueSize
        self.infoView.width = layoutFrame.width - expandButtonSize.width
    }
    
    func updateInfo() {
        infoView.imageContent = .withName(group?.iconName)
        infoView.title = group?.name
        valueLabel.text = "\(group?.tasks?.count ?? 0)"
        setNeedsLayout()
    }
    
    // MARK: - Event Response
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        TPImpactFeedback.impactWithSoftStyle()
        clickExpand()
    }
    
    /// 点击展开或收起按钮
    @objc private func clickExpand() {
        let isExpanded = !expandButton.isExpanded
        setExpanded(isExpanded, animated: true)
        
        if let delegate = self.delegate as? HabitTaskListGroupHeaderViewDelegate {
            delegate.groupHeaderView(self, didToggleExpand: isExpanded)
        }
    }
    
    func setExpanded(_ isExpanded: Bool, animated: Bool) {
        guard expandButton.isExpanded != isExpanded else {
            return
        }
        
        expandButton.setExpanded(isExpanded, animated: animated)
    }
    
    func updateExpanded(animated: Bool) {
        guard let delegate = delegate as? HabitTaskListGroupHeaderViewDelegate else {
            return
        }
        
        let isExpanded = delegate.isExpandedGroupHeaderView(self)
        setExpanded(isExpanded, animated: animated)
    }
}
