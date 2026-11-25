//
//  WSHabitSmallMonthReportContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 习惯·小·月报告的内容视图。
///
/// 上方为任务图标与名称，下方整个区域按习惯报告页的样式绘制本月热力图。
class WSHabitSmallMonthReportContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 信息视图高度
        static let infoHeight: CGFloat = 24.0
        
        /// 信息视图与月报告的间距
        static let infoReportSpacing: CGFloat = 4.0
        
        /// 图标边长
        static let iconSize = CGSize(value: 32.0)
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
    }
    
    /// 任务图标与名称
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.iconSize = Metrics.iconSize
        view.iconView.font = .boldSystemFont(ofSize: 24.0)
        view.titleView.titleConfig = .withFont(Metrics.titleFont,
                                               numberOfLines: 1,
                                               textColor: .label,
                                               adjustsFontSizeToFitWidth: true,
                                               minimumScaleFactor: 0.7)
        return view
    }()
    
    /// 本月热力图
    private let reportView = WSHabitMonthReportView()
    
    /// 当前展示的月报告数据
    private var reportDataItem: WSHabitPeriodDataItem? {
        return dataItem as? WSHabitPeriodDataItem
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        infoView.iconView.font = .boldSystemFont(ofSize: 24.0)
        addSubview(infoView)
        addSubview(reportView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        infoView.frame = CGRect(x: layoutFrame.minX,
                                y: layoutFrame.minY,
                                width: layoutFrame.width,
                                height: Metrics.infoHeight)
        
        /// 信息视图以下的区域全部留给月报告
        reportView.width = layoutFrame.width
        reportView.height = max(layoutFrame.maxY - infoView.bottom - Metrics.infoReportSpacing, 0.0)
        reportView.left = layoutFrame.minX
        reportView.top = infoView.bottom + Metrics.infoReportSpacing
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = reportDataItem else {
            infoView.isHidden = true
            infoView.icon = nil
            infoView.title = nil
            reportView.dayItems = []
            setNeedsLayout()
            return
        }
        
        infoView.isHidden = false
        infoView.icon = dataItem.icon
        infoView.title = dataItem.title
        reportView.firstWeekday = HabitSetting.shared.firstWeekday
        reportView.dayItems = dataItem.days
        setNeedsLayout()
    }
}
