//
//  WSFocusSmallTodayComparisonContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 专注·小·今日对比的内容视图。
///
/// 自上而下展示今日标题、今日时长与较昨日的增减，底部为昨日时长。
class WSFocusSmallTodayComparisonContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 16.0)
        
        /// 标题图标尺寸
        static let iconSize: CGFloat = 18.0
        
        /// 图标与标题间距
        static let iconTitleSpacing: CGFloat = 6.0
        
        /// 标题与今日时长的间距
        static let headerValueSpacing: CGFloat = 2.0
        
        /// 标题与副标题的间距
        static let infoSpacing: CGFloat = 2.0
        
        /// 标题字体
        static let headerFont = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        
        /// 今日时长字体
        static let valueFont = UIFont.boldSystemFont(ofSize: 30.0)
        
        /// 今日时长单位字体
        static let valueUnitFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 增减字体
        static let deltaFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        
        /// 昨日标题字体
        static let footerTitleFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 昨日时长字体
        static let footerValueFont = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        
        /// 昨日时长单位字体
        static let footerUnitFont = UIFont.boldSystemFont(ofSize: 12.0)
        
        /// 专注主色
        static let accentColor = Color(0x4A4DFF)
        
        /// 增加
        static let increaseColor = Color(0x66D065)
        
        /// 减少
        static let decreaseColor = Color(0xF66464)
    }
    
    /// 图标 + 今日标题
    private lazy var titleView: TPIconTitleView = {
        let view = TPIconTitleView()
        view.icon = TPIcon(name: "focus_stats_group_timer_24")
        view.foreColor = Metrics.accentColor
        view.accessorySize = CGSize(width: Metrics.iconSize, height: Metrics.iconSize)
        view.accessoryMargins = UIEdgeInsets(right: Metrics.iconTitleSpacing)
        view.titleConfig = .withFont(Metrics.headerFont, textColor: Metrics.accentColor)
        view.title = resGetString("Today's Focus")
        return view
    }()
    
    /// 今日时长与增减
    private let infoView = TPInfoView()
    
    /// 昨日标题与昨日时长
    private let footerInfoView = TPInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        infoView.titleConfig = .withFont(Metrics.valueFont,
                                         textColor: .label,
                                         adjustsFontSizeToFitWidth: true,
                                         minimumScaleFactor: 0.5)
        infoView.subtitleConfig = .withFont(Metrics.deltaFont, textColor: Metrics.increaseColor)
        infoView.subtitleTopMargin = Metrics.infoSpacing
        
        footerInfoView.titleConfig = .withFont(Metrics.footerTitleFont, textColor: .tertiaryLabel)
        footerInfoView.subtitleConfig = .withFont(Metrics.footerValueFont, textColor: .secondaryLabel)
        footerInfoView.subtitleTopMargin = Metrics.infoSpacing
        footerInfoView.title = resGetString("Yesterday's Focus")
        
        addSubview(titleView)
        addSubview(infoView)
        addSubview(footerInfoView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentFrame = layoutFrame()
        guard contentFrame.width > 0.0 && contentFrame.height > 0.0 else {
            return
        }
        
        titleView.size = CGSize(width: contentFrame.width, height: Metrics.iconSize)
        titleView.origin = contentFrame.origin
        
        /// 今日时长与增减紧接标题
        let infoHeight = ceil(Metrics.valueFont.lineHeight)
            + Metrics.infoSpacing
            + ceil(Metrics.deltaFont.lineHeight)
        infoView.size = CGSize(width: contentFrame.width, height: infoHeight)
        infoView.left = contentFrame.minX
        infoView.top = titleView.bottom + Metrics.headerValueSpacing
        
        /// 昨日信息贴底
        let footerHeight = ceil(Metrics.footerTitleFont.lineHeight)
            + Metrics.infoSpacing
            + ceil(Metrics.footerValueFont.lineHeight)
        footerInfoView.size = CGSize(width: contentFrame.width, height: footerHeight)
        footerInfoView.left = contentFrame.minX
        footerInfoView.bottom = contentFrame.maxY
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSFocusTodayComparisonDataItem else {
            infoView.title = nil
            infoView.subtitle = nil
            footerInfoView.subtitle = nil
            setNeedsLayout()
            return
        }
        
        infoView.title = dataItem.today.attributedTitle(symbolFont: Metrics.valueUnitFont)
        footerInfoView.subtitle = dataItem.yesterday.attributedTitle(symbolFont: Metrics.footerUnitFont)
        updateDelta(with: dataItem.delta)
        
        setNeedsLayout()
    }
    
    private func updateDelta(with delta: Duration) {
        let color: UIColor
        if delta > 0 {
            infoView.subtitle = "↑ \(delta.title)"
            color = Metrics.increaseColor
        } else if delta < 0 {
            infoView.subtitle = "↓ \((-delta).title)"
            color = Metrics.decreaseColor
        } else {
            infoView.subtitle = "0m"
            color = .secondaryLabel
        }
        
        infoView.subtitleConfig.textColor = color
    }
}
