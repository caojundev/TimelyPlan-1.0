//
//  TodoOverdueGroupHeaderView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/12.
//

import Foundation

protocol TodoGroupOverdueHeaderViewDelegate: TodoGroupBaseHeaderViewDelegate {
    
    /// 点击重新安排
    func overdueHeaderViewDidClickReschedule(_ headerView: TodoGroupOverdueHeaderView)
}

class TodoGroupOverdueHeaderView: TodoGroupNormalHeaderView {
    
    /// 重新安排按钮
    private(set) lazy var rescheduleButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Reschedule")
        button.padding = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.cornerRadius = 8.0
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.addTarget(self,
                         action: #selector(clickReschedule(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    
    override func setupContentSubViews() {
        super.setupContentSubViews()
        contentView.addSubview(rescheduleButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        rescheduleButton.sizeToFit()
        rescheduleButton.centerY = layoutFrame.midY
        rescheduleButton.right = countLabel.left - 5.0
        
        let expandButtonMaxWidth = rescheduleButton.left - layoutFrame.minX - 5.0
        if expandButton.width > expandButtonMaxWidth {
            expandButton.width = expandButtonMaxWidth
        }
    }
    
    /// 点击展开或收起按钮
    @objc func clickReschedule(_ button: UIButton) {
        if let delegate = self.delegate as? TodoGroupOverdueHeaderViewDelegate {
            delegate.overdueHeaderViewDidClickReschedule(self)
        }
    }
}
