//
//  CalendarPanelFourPlusFourSingleView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/30.
//

import Foundation
import UIKit

/// 「4 + 4」样式的页面视图：左上角挂件为月历小视图
class CalendarPanelFourPlusFourSingleView: CalendarPanelSingleView {
    
    /// 左上角月历挂件
    private lazy var miniMonthView = CalendarPanelMiniMonthView()
    
    override init(style: CalendarPanelStyle) {
        super.init(style: style)
        setupMiniMonthView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutMiniMonthView()
    }
    
    /// 挂件数据：显示 firstDay 所在月份的月历
    override func reloadWidgets() {
        super.reloadWidgets()
        miniMonthView.firstWeekday = firstWeekday
        miniMonthView.firstDay = firstDay
    }
    
    // MARK: - Setup
    
    private func setupMiniMonthView() {
        miniMonthView.didSelectDate = { [weak self] date in
            guard let self = self else {
                return
            }
            
            /// 月历挂件选中日期：交给上层跳转到该日期
            self.delegate?.calendarPanelSingleView(self, didSelectDate: date)
        }
        
        addSubview(miniMonthView)
    }
    
    // MARK: - Layout
    
    /// 挂件位置由布局对象按样式的挂件配置计算
    private func layoutMiniMonthView() {
        guard let frame = widgetFrame(at: 0) else {
            return
        }
        
        miniMonthView.frame = frame
    }
}
