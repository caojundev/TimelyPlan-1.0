//
//  WSHabitWeekReportRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 习惯周报告行视图。
///
/// 左侧任务图标与名称，右侧一行七天的报告色块，整行响应点击。
class WSHabitWeekReportRowView: WSRowView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 按下高亮的圆角
        static let cornerRadius: CGFloat = 10.0
        
        /// 图标边长
        static let iconSize = CGSize(value: 32.0)
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 信息区与行边缘的间距
        static let infoInsets = UIEdgeInsets(horizontal: 4.0)
        
        /// 图标与标题的间距
        static let titleSpacing: CGFloat = 6.0
        
        /// 信息区宽度占行宽的比例
        static let infoWidthRatio: CGFloat = 0.42
        
        /// 信息区与周视图的间距
        static let weekSpacing: CGFloat = 8.0
        
        /// 内容与行右边缘的间距
        static let rightInset: CGFloat = 4.0
    }
    
    /// 任务图标与名称
    private(set) lazy var infoView: HabitReportIconInfoView = {
        let view = HabitReportIconInfoView()
        view.iconSize = Metrics.iconSize
        view.iconView.font = .boldSystemFont(ofSize: 24.0)
        
        view.padding = Metrics.infoInsets
        view.titleView.titleConfig = .withFont(Metrics.titleFont,
                                               numberOfLines: 1,
                                               textColor: .label,
                                               adjustsFontSizeToFitWidth: true,
                                               minimumScaleFactor: 0.8)
        return view
    }()
    
    /// 本周报告
    private let weekView = WSHabitWeekReportView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentCornerRadius = Metrics.cornerRadius
        /// 行不响应点击，避免触发按下高亮与触感反馈
        isUserInteractionEnabled = false
        
        addSubview(infoView)
        addSubview(weekView)
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
        
        infoView.frame = CGRect(x: 0.0,
                                y: 0.0,
                                width: floor(bounds.width * Metrics.infoWidthRatio),
                                height: bounds.height)
        
        let weekLeft = infoView.right + Metrics.weekSpacing
        weekView.frame = CGRect(x: weekLeft,
                                y: 0.0,
                                width: max(bounds.width - weekLeft - Metrics.rightInset, 0.0),
                                height: bounds.height)
    }
    
    // MARK: - 渲染
    /// 更新展示的时间段数据。传 nil 时清空内容
    func update(with dataItem: WSHabitPeriodDataItem?) {
        guard let dataItem = dataItem else {
            infoView.icon = nil
            infoView.title = nil
            weekView.dayItems = []
            return
        }
        
        infoView.icon = dataItem.icon
        infoView.title = dataItem.title
        weekView.dayItems = dataItem.days
    }
}
