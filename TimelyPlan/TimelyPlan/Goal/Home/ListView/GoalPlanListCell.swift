//
//  GoalPlanListCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

protocol GoalPlanListCellDelegate: AnyObject {
    /// 点击更多
    func goalPlanListCellDidClickMore(_ cell: GoalPlanListCell)
}

class GoalPlanCellStyle: TPCollectionCellStyle {
    
    override init() {
        super.init()
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectedBackgroundColor = .tertiarySystemGroupedBackground
        self.cornerRadius = 12.0
    }
}

class GoalPlanListCell: TPDefaultInfoCollectionCell {
    
    /// 目标计划
    var goalPlan: GoalPlan? {
        didSet {
            self.updateInfo()
        }
    }
    
    let kInfoViewMargin = 10.0
    
    let kIndicatorSize = CGSize(width: 6.0, height: 36.0)
    
    /// 颜色指示器
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.size = kIndicatorSize
        view.layer.cornerRadius = kIndicatorSize.width / 2.0
        return view
    }()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        self.contentView.padding = UIEdgeInsets(top: 5.0, left: 16.0, bottom: 5.0, right: 10.0)
        contentView.addSubview(indicatorView)
        contentView.addSubview(moreButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
        
        indicatorView.size = kIndicatorSize
        indicatorView.left = layoutFrame.minX
        indicatorView.alignVerticalCenter()
        
        moreButton.sizeToFit()
        moreButton.right = layoutFrame.maxX
        moreButton.alignVerticalCenter()
        
        infoView.width = layoutFrame.width - indicatorView.width - moreButton.width - kInfoViewMargin * 2
        infoView.height = layoutFrame.height
        infoView.left = indicatorView.right + kInfoViewMargin
        infoView.top = layoutFrame.minY
    }
    
    /// 更新信息
    func updateInfo() {
        guard let goalPlan = goalPlan else {
            return
        }
        
        indicatorView.backgroundColor = goalPlan.color
        infoView.title = goalPlan.displayName
        
        /// 副标题：日期区间
        var subtitleComponents = [ASAttributedString]()
        let intervalString = GoalDateHelper.intervalDescription(startDate: goalPlan.startDate,
                                                                endDate: goalPlan.endDate)
        if let intervalString = intervalString {
            subtitleComponents.append(intervalString.attributedString)
        }
        
        infoView.subtitle = subtitleComponents.joined(separator: " • ")
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? GoalPlanListCellDelegate {
            delegate.goalPlanListCellDidClickMore(self)
        }
    }
}
