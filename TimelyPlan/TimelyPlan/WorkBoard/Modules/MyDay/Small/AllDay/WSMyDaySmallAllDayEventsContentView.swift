//
//  WSMyDaySmallAllDayEventsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 我的一天·小·全天事项的内容视图。
///
/// 使用简略行展示全天事项，行高更紧凑。
class WSMyDaySmallAllDayEventsContentView: WSMyDayAllDayEventsContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 8.0)
        
        /// 行的最小与最大高度
        static let rowMinimumHeight: CGFloat = 20.0
        static let rowMaximumHeight: CGFloat = 28.0
        
        /// 行间距
        static let rowSpacing: CGFloat = 2.0
        
        /// 更多入口的左缩进，与行内名称对齐
        static let moreLeadingInset: CGFloat = 18.0
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
        return WSMyDayBriefAllDayEventRowView()
    }
}
