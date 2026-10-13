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
    
    /// 状态标签与更多按钮的间距
    let statusMoreSpacing = 8.0
    
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
    
    /// 状态标签（圆角胶囊，标题与背景色取自目标计划状态）
    lazy var statusLabel: TPLabel = {
        let label = TPLabel()
        label.font = .systemFont(ofSize: 10.0, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.edgeInsets = UIEdgeInsets(horizontal: 6.0, vertical: 5.0)
        return label
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
        contentView.addSubview(infoView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(moreButton)
    
        contentView.addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layoutFrame = contentView.layoutFrame()
    
        /// 状态标签与更多按钮贴右排布，其宽度从信息视图中扣除，避免标题被遮挡
        statusLabel.sizeToFit()
        moreButton.size = .mini
        let accessoryWidth = statusLabel.width + statusMoreSpacing + moreButton.width
        
        infoView.width = max(0.0, layoutFrame.width - accessoryWidth)
        infoView.height = layoutFrame.height - progressHeight - progressMargins.verticalLength
        infoView.left = layoutFrame.minX
        infoView.top = layoutFrame.minY
        
        /// 更多按钮贴右，状态标签紧随其左侧，二者与信息视图垂直居中
        moreButton.right = layoutFrame.maxX
        moreButton.centerY = infoView.centerY
        statusLabel.right = moreButton.left - statusMoreSpacing
        statusLabel.centerY = moreButton.centerY
        statusLabel.layer.cornerRadius = statusLabel.halfHeight

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
        
        let color = goalPlan.color ?? GoalConfig.goalPlanDefaultColor
        progressView.barForeColor = color
        progressView.barBackColor = color.withAlphaComponent(0.2)
        progressView.setProgress(goalPlan.progress, animated: false)
        infoView.color = goalPlan.color
        infoView.title = goalPlan.displayName
        
        /// 状态标签：标题与背景色取自目标计划状态；
        /// 进行中时改用进度总结状态（领先 / 正常 / 落后…），比「进行中」更有信息量
        let status = goalPlan.status
        if status == .inProgress {
            let summaryStatus = goalPlan.summaryStatus
            statusLabel.text = summaryStatus.title
            statusLabel.layer.backgroundColor = summaryStatus.backgroundColor.cgColor
        } else {
            statusLabel.text = status.title
            statusLabel.layer.backgroundColor = status.backgroundColor.cgColor
        }
        
        /// 副标题：由 GoalPlanDetailProvider 统一计算（日期区间 + 进度百分比）
        infoView.subtitle = GoalPlanDetailProvider.detail(for: goalPlan)
        
        /// 标签宽度随状态文案变化，需要重新布局
        setNeedsLayout()
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
