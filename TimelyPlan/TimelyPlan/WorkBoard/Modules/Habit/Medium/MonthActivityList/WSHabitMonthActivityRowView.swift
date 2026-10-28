//
//  WSHabitMonthActivityRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 习惯月度活动行视图。
///
/// 上方左侧为任务图标、名称与目标，右侧为本月完成的天数；
/// 下方为一行按天绘制的活动条。
class WSHabitMonthActivityRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 内容与行左右边缘的间距
        static let leftInset: CGFloat = 12.0
        static let rightInset: CGFloat = 12.0
        
        /// 图标边长范围
        static let minIconSide: CGFloat = 40.0
        static let maxIconSide: CGFloat = 44.0
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 13.0)
        
        /// 副标题字号
        static let subtitleFont = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        
        /// 图标与文案的间距
        static let titleSpacing: CGFloat = 8.0
        
        /// 标题与副标题的间距
        static let subtitleTopMargin: CGFloat = 1.0
        
        /// 完成天数区域宽度
        static let countWidth: CGFloat = 46.0
        
        /// 完成天数的符号与数字字号
        static let countSymbolFont = UIFont.boldSystemFont(ofSize: 13.0)
        static let countFont = UIFont.boldSystemFont(ofSize: 20.0)
        
        /// 活动条高度及与上方的间距
        static let barHeight: CGFloat = 12.0
        static let barSpacing: CGFloat = 8.0
    }
    
    /// 任务图标、名称与目标
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.padding = UIEdgeInsets(left: Metrics.leftInset)
        view.iconView.cornerRadius = .greatestFiniteMagnitude
        
        let titleView = view.titleView
        titleView.padding = UIEdgeInsets(left: Metrics.titleSpacing)
        titleView.subtitleTopMargin = Metrics.subtitleTopMargin
        titleView.titleConfig = .withFont(Metrics.titleFont,
                                          numberOfLines: 1,
                                          textColor: .label,
                                          adjustsFontSizeToFitWidth: true,
                                          minimumScaleFactor: 0.7)
        
        let subtitleConfig = TPLabelConfig.withFont(Metrics.subtitleFont,
                                                    numberOfLines: 1,
                                                    textColor: .secondaryLabel,
                                                    adjustsFontSizeToFitWidth: true,
                                                    minimumScaleFactor: 0.7)
        subtitleConfig.alpha = 0.8
        titleView.subtitleConfig = subtitleConfig
        return view
    }()
    
    /// 本月完成的天数
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    /// 本月每天的活动条
    private let activityBarView = WSHabitMonthActivityBarView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        /// 行不响应点击，避免触发按下高亮与触感反馈
        isUserInteractionEnabled = false
        
        addSubview(infoView)
        addSubview(countLabel)
        addSubview(activityBarView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0.0, bounds.height > 0.0 else {
            return
        }
        
        let barHeight = min(Metrics.barHeight, bounds.height)
        let availableHeight = max(bounds.height - barHeight - Metrics.barSpacing, 0.0)
        
        /// 信息区高度取文案高度、图标与文案等高，避免信息区被拉伸后把活动条顶到行底部
        let textHeight = ceil(Metrics.titleFont.lineHeight)
            + Metrics.subtitleTopMargin
            + ceil(Metrics.subtitleFont.lineHeight)
        let iconSide = min(max(textHeight, Metrics.minIconSide), Metrics.maxIconSide, availableHeight)
        let infoHeight = min(max(iconSide, textHeight), availableHeight)
        
        /// 信息区与活动条作为整体在行内垂直居中
        let contentHeight = infoHeight + Metrics.barSpacing + barHeight
        let contentTop = max((bounds.height - contentHeight) / 2.0, 0.0)
        
        /// 上方左侧留给图标与文案，右侧固定宽度展示完成天数
        let infoWidth = max(bounds.width - Metrics.countWidth - Metrics.rightInset, 0.0)
        infoView.frame = CGRect(x: 0.0, y: contentTop, width: infoWidth, height: infoHeight)
        infoView.iconSize = CGSize(value: iconSide)
        
        countLabel.frame = CGRect(x: bounds.width - Metrics.rightInset - Metrics.countWidth,
                                  y: contentTop,
                                  width: Metrics.countWidth,
                                  height: infoHeight)
        
        /// 活动条顶部距离信息区底部 barSpacing，左端与标题左端对齐
        let barLeft = Metrics.leftInset + iconSide + Metrics.titleSpacing
        activityBarView.frame = CGRect(x: barLeft,
                                       y: infoView.bottom + Metrics.barSpacing,
                                       width: max(bounds.width - barLeft - Metrics.rightInset, 0.0),
                                       height: barHeight)
    }
    
    // MARK: - 渲染
    /// 更新展示的时间段数据。传 nil 时清空内容
    func update(with dataItem: WSHabitPeriodDataItem?) {
        guard let dataItem = dataItem else {
            infoView.icon = nil
            infoView.title = nil
            infoView.titleView.subtitle = nil
            countLabel.attributedText = nil
            activityBarView.dayItems = []
            return
        }
        
        infoView.icon = dataItem.icon
        infoView.iconView.backColor = dataItem.color
        infoView.title = dataItem.title
        infoView.titleView.subtitle = dataItem.subtitle
        countLabel.attributedText = Self.countText(for: dataItem.completedDaysCount)
        activityBarView.dayItems = dataItem.days
    }
    
    /// 完成天数文案，符号字号小于数字
    private static func countText(for count: Int) -> NSAttributedString {
        let text = NSMutableAttributedString(string: "×",
                                             attributes: [.font: Metrics.countSymbolFont,
                                                          .foregroundColor: UIColor.secondaryLabel])
        text.append(NSAttributedString(string: "\(count)",
                                       attributes: [.font: Metrics.countFont,
                                                    .foregroundColor: UIColor.label]))
        return text
    }
}
