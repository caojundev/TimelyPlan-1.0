//
//  WSHabitMonthActivityBarView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation
import UIKit

// MARK: - 本月活动条视图

/// 本月活动条视图。
///
/// 按当月天数等分绘制直角色块，色块透明度随当天完成比例变化：
/// 已完成使用任务颜色，进行中按进度叠加透明度，未开始与非计划日使用占位底色。
/// 圆角由视图自身裁剪，因此只有整条活动条的两端呈圆角，中间色块保持直边。
class WSHabitMonthActivityBarView: UIView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 相邻两天之间的间距
        static let itemSpacing: CGFloat = 2.0
        
        /// 进度色块透明度的下限
        static let minProgressAlpha: CGFloat = 0.2
    }
    
    /// 当月每天的数据，按日期顺序排列
    var dayItems: [WSHabitDayDataItem] = [] {
        didSet {
            setNeedsDisplay()
            /// 天数变化会改变色块宽度，圆角需要随之更新
            setNeedsLayout()
        }
    }
    
    /// 单天色块宽度
    private var itemWidth: CGFloat {
        let count = CGFloat(dayItems.count)
        guard count > 0.0 else {
            return 0.0
        }
        
        return max((bounds.width - Metrics.itemSpacing * (count - 1.0)) / count, 0.0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
        /// 尺寸变化时由 contentMode 触发重绘
        contentMode = .redraw
        /// 裁剪出整条活动条两端的圆角
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 圆角半径取行高的一半，色块过窄时按色块宽度收缩
        layer.cornerRadius = bounds.height / 2.0
    }
    
    // MARK: - 绘制
    override func draw(_ rect: CGRect) {
        let itemWidth = self.itemWidth
        guard !dayItems.isEmpty, bounds.height > 0.0, itemWidth > 0.0 else {
            return
        }
        
        for (index, dayItem) in dayItems.enumerated() {
            let itemFrame = CGRect(x: CGFloat(index) * (itemWidth + Metrics.itemSpacing),
                                   y: 0.0,
                                   width: itemWidth,
                                   height: bounds.height)
            fillColor(for: dayItem).setFill()
            UIBezierPath(rect: itemFrame).fill()
        }
    }
    
    /// 色块颜色：有进度时按完成比例叠加任务颜色
    private func fillColor(for dayItem: WSHabitDayDataItem) -> UIColor {
        guard dayItem.isScheduled else {
            return .quaternarySystemFill
        }
        
        switch dayItem.status {
        case .skipped(_), .failed(_):
            return .tertiarySystemFill
        case .notStarted, .inProgress, .completed:
            guard dayItem.progress > 0.0 else {
                return .secondarySystemFill
            }
            
            let alpha = min(max(dayItem.progress, Metrics.minProgressAlpha), 1.0)
            return dayItem.color.withAlphaComponent(alpha)
        }
    }
}
