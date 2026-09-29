//
//  CalendarPanelSingleView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

/// 面板的一个页面：按样式创建天元素视图，并交给布局对象计算位置
class CalendarPanelSingleView: UIView {
    
    /// 页面显示的第一天
    var firstDay: Date? {
        didSet {
            guard firstDay != oldValue else {
                return
            }
            
            reloadDayData()
        }
    }
    
    /// 面板布局样式：决定页面中天元素视图的个数、每个视图显示的天数及其位置
    var panelStyle: CalendarPanelStyle {
        get {
            return layout.style
        }
        
        set {
            guard newValue != layout.style else {
                return
            }
            layout.style = newValue
            reloadData()
        }
    }
    
    /// 布局对象：负责所有位置计算
    private let layout = CalendarPanelLayout()
    
    /// 当前页面中的天元素视图
    private var elementViews: [CalendarPanelElementView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutElementViews()
    }
    
    // MARK: - Data
    
    func reloadData() {
        reloadElementViews()
        reloadDayData()
        setNeedsLayout()
    }
    
    /// 根据样式创建 / 复用天元素视图（个数是动态的）
    private func reloadElementViews() {
        let itemCount = layout.numberOfDayItems
        
        if elementViews.count > itemCount {
            elementViews[itemCount...].forEach { $0.removeFromSuperview() }
            elementViews.removeLast(elementViews.count - itemCount)
        }
        
        while elementViews.count < itemCount {
            let elementView = CalendarPanelElementView()
            addSubview(elementView)
            elementViews.append(elementView)
        }
    }
    
    /// 刷新每个天元素视图显示的天（一天或多天）
    private func reloadDayData() {
        // 天元素视图个数与样式不一致时先同步视图
        if elementViews.count != layout.numberOfDayItems {
            reloadElementViews()
        }
        
        let firstDay = self.firstDay?.startOfDay()
        for (index, item) in layout.config.dayItems.enumerated() {
            guard index < elementViews.count else {
                break
            }
            
            let elementView = elementViews[index]
            elementView.update(firstDay: firstDay?.dateByAddingDays(item.dayOffset),
                               dayCount: item.dayCount)
        }
    }
    
    /// 应用布局对象计算出的位置
    private func layoutElementViews() {
        let itemLayouts = layout.dayItemLayouts(in: bounds)
        for (index, itemLayout) in itemLayouts.enumerated() {
            guard index < elementViews.count else {
                break
            }
            elementViews[index].frame = itemLayout.frame
        }
    }
}
