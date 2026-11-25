//
//  WSMyDayLargeAllDayEventsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 我的一天·大·全天事项的内容视图。
///
/// 与中尺寸一致使用详细行，可用高度更大，展示的行数更多。
class WSMyDayLargeAllDayEventsContentView: WSMyDayAllDayEventsContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 16.0)
        
        /// 行的最小与最大高度
        static let rowMinimumHeight: CGFloat = 30.0
        static let rowMaximumHeight: CGFloat = 44.0
        
        /// 行间距
        static let rowSpacing: CGFloat = 4.0
        
        /// 更多入口的左缩进，与行内名称对齐
        static let moreLeadingInset: CGFloat = 38.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        self.rowMinimumHeight = Metrics.rowMinimumHeight
        self.rowMaximumHeight = Metrics.rowMaximumHeight
        self.rowSpacing = Metrics.rowSpacing
        self.moreLeadingInset = Metrics.moreLeadingInset
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 行视图
    override func makeRowView() -> WSMyDayAllDayEventRowBaseView {
        return WSMyDayDetailAllDayEventRowView()
    }
}
