//
//  CountdownMilestoneCollectionCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/21.
//

import Foundation
import UIKit

// MARK: - 里程碑集合单元格
/// 里程碑集合视图单元格
class CountdownMilestoneCollectionCell: TPDefaultInfoCollectionCell {
    
    static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
    
    /// 里程碑
    var milestoneItem: CountdownMilestoneItem? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        titleConfig.font = Self.titleFont
        titleConfig.textAlignment = .center
        titleConfig.selectedTextColor = .white
        titleConfig.adjustsFontSizeToFitWidth = true
        
        subtitleConfig.font = .systemFont(ofSize: 11.0, weight: .medium)
        subtitleConfig.textAlignment = .center
        subtitleConfig.selectedTextColor = .white
        subtitleConfig.adjustsFontSizeToFitWidth = true
        scaleWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTitle()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        setNeedsLayout()
    }
    
    /// 更新标题
    func updateTitle() {
        guard let milestoneItem = milestoneItem else {
            infoView.title = nil
            infoView.subtitle = nil
            return
        }
        
        let milestone = milestoneItem.milestone
        infoView.title = milestone.title
        
        let targetDate = milestoneItem.date?.date(for: milestone)
        infoView.subtitle = targetDate?.displayText
    }
}
