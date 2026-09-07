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

class GoalPlanListCell: TPCollectionCell {
    
    /// 单元格默认高度
    static let cellHeight = 100.0
    
    /// 目标计划
    var goalPlan: GoalPlan? {
        didSet {
            self.updateInfo()
        }
    }
    
    /// 进度条高度
    let progressHeight = 8.0
    
    let progressMargins = UIEdgeInsets(top: 8.0,
                                       left: 20.0,
                                       bottom: 0.0,
                                       right: 24.0)
    
    /// 信息视图
    let infoView = GoalPlanListInfoView()
    
    /// 更多按钮
    lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton.moreButton()
        button.imageConfig.color = .secondaryLabel
        button.addTarget(self,
                         action: #selector(clickMore(_:)),
                         for: .touchUpInside)
        return button
    }()
    
    /// 进度视图
    private(set) lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.isUserInteractionEnabled = false
        view.cornerRadius = .greatestFiniteMagnitude
        return view
    }()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        
        contentView.padding = UIEdgeInsets(top: 15.0,
                                           left: 16.0,
                                           bottom: 15.0,
                                           right: 12.0)
        infoView.rightAccessoryView = moreButton
        infoView.rightAccessorySize = .mini
        infoView.rightAccessoryMargins = UIEdgeInsets(left: 4.0)
        contentView.addSubview(infoView)
    
        contentView.addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
    
        infoView.width = layoutFrame.width
        infoView.height = layoutFrame.height - progressHeight - progressMargins.verticalLength
        infoView.left = layoutFrame.minX
        infoView.top = layoutFrame.minY

        /// 进度条位于底部
        progressView.width = layoutFrame.width - progressMargins.horizontalLength
        progressView.height = progressHeight
        progressView.left = layoutFrame.minX + progressMargins.left
        progressView.bottom = layoutFrame.maxY - progressMargins.bottom
    }
    
    /// 更新信息
    func updateInfo() {
        guard let goalPlan = goalPlan else {
            return
        }
        
        progressView.barForeColor = goalPlan.color
        progressView.barBackColor = goalPlan.color.withAlphaComponent(0.2)
        progressView.setProgress(goalPlan.progress, animated: false)
        infoView.color = goalPlan.color
        infoView.title = goalPlan.displayName
        
        /// 副标题：由 GoalPlanDetailProvider 统一计算（日期区间 + 进度百分比）
        infoView.subtitle = GoalPlanDetailProvider.detail(for: goalPlan)
    }
    
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        if let delegate = delegate as? GoalPlanListCellDelegate {
            delegate.goalPlanListCellDidClickMore(self)
        }
    }
}

class GoalPlanListInfoView: TPInfoView {
    
    var color: UIColor? {
        get {
            return colorView.backgroundColor
        }
        
        set {
            colorView.backgroundColor = newValue
        }
    }
    
    private let colorView = UIView()
    
    override func setupSubviews() {
        super.setupSubviews()
        colorView.clipsToBounds = true
        subtitleTopMargin = 8.0
        leftAccessoryView = colorView
        leftAccessorySize = .size(3)
        leftAccessoryMargins = UIEdgeInsets(right: 8.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = colorView.halfWidth
        colorView.centerY = titleLabel.centerY
    }
    
}

class GoalPlanDetailProvider {
    
    /// 副标题组件：日期区间 + 进度百分比
    static func subtitleComponents(for goalPlan: GoalPlan) -> [ASAttributedString] {
        var components = [ASAttributedString]()
        
        /// 日期区间
        let intervalString = GoalDateHelper.intervalDescription(startDate: goalPlan.startDate,
                                                                endDate: goalPlan.endDate)
        if let intervalString = intervalString {
            components.append(intervalString.attributedString)
        }
        
        /// 当前进度百分比（不保留小数位）
        let progressString = Float(goalPlan.progress).percentageString(decimalPlaces: 0)
        components.append(progressString.attributedString)
        
        return components
    }
    
    static func detail(for goalPlan: GoalPlan) -> ASAttributedString {
        return subtitleComponents(for: goalPlan).joined(separator: " • ")
    }
    
}
