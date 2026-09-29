//
//  CalendarPanelLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

/// 单个天元素视图的布局信息
struct CalendarPanelDayItemLayout {
    /// 天元素视图在页面中的位置
    let frame: CGRect
    /// 元素视图起始天在页面中的偏移（相对页面第一天，从 0 开始）
    let dayOffset: Int
    /// 元素视图显示的天数：1 为单天视图，大于 1 为多天视图
    let dayCount: Int
}

/// 面板布局计算对象：根据样式配置和当前页面尺寸，计算每个天元素视图的位置
final class CalendarPanelLayout {
    
    /// 面板样式
    var style: CalendarPanelStyle {
        didSet {
            guard style != oldValue else {
                return
            }
            config = CalendarPanelLayoutConfig(style: style)
        }
    }
    
    /// 页面内容内边距
    var contentInsets: UIEdgeInsets = .zero
    
    /// 相邻天元素视图之间的间距（元素之间留白时使用）
    var interitemSpacing: CGFloat = 0
    
    /// 当前样式的布局配置
    private(set) var config: CalendarPanelLayoutConfig
    
    init(style: CalendarPanelStyle = .threePlusFourVertical) {
        self.style = style
        self.config = CalendarPanelLayoutConfig(style: style)
    }
    
    /// 页面中天元素视图的个数（由样式决定）
    var numberOfDayItems: Int {
        return config.dayItems.count
    }
    
    /// 页面显示的总天数
    var daysInPage: Int {
        return config.daysInPage
    }
    
    /// 计算页面中所有天元素视图的布局
    /// - Parameter pageBounds: 页面尺寸
    /// - Returns: 与 `config.dayItems` 顺序一致的天元素视图布局
    func dayItemLayouts(in pageBounds: CGRect) -> [CalendarPanelDayItemLayout] {
        guard let unitSize = unitSize(in: pageBounds) else {
            return []
        }
        
        let contentFrame = pageBounds.inset(by: contentInsets)
        return config.dayItems.map { item in
            return dayItemLayout(for: item, unitSize: unitSize, in: contentFrame)
        }
    }
    
    /// 计算指定天元素视图的布局
    func dayItemLayout(at index: Int, in pageBounds: CGRect) -> CalendarPanelDayItemLayout? {
        guard index >= 0, index < numberOfDayItems, let unitSize = unitSize(in: pageBounds) else {
            return nil
        }
        
        return dayItemLayout(for: config.dayItems[index],
                             unitSize: unitSize,
                             in: pageBounds.inset(by: contentInsets))
    }
    
    // MARK: - Private
    
    /// 单位长宽：把页面按行、列分块后每一块的大小
    private func unitSize(in pageBounds: CGRect) -> CGSize? {
        let grid = config.grid
        guard grid.rows > 0, grid.columns > 0 else {
            return nil
        }
        
        let contentFrame = pageBounds.inset(by: contentInsets)
        guard contentFrame.width > 0, contentFrame.height > 0 else {
            return nil
        }
        
        return CGSize(width: contentFrame.width / CGFloat(grid.columns),
                      height: contentFrame.height / CGFloat(grid.rows))
    }
    
    /// 根据单位长宽和块坐标计算元素视图的 frame
    private func dayItemLayout(for item: CalendarPanelDayItemConfig,
                               unitSize: CGSize,
                               in contentFrame: CGRect) -> CalendarPanelDayItemLayout {
        let frame = CGRect(x: contentFrame.minX + CGFloat(item.column) * unitSize.width,
                           y: contentFrame.minY + CGFloat(item.row) * unitSize.height,
                           width: CGFloat(item.columnSpan) * unitSize.width,
                           height: CGFloat(item.rowSpan) * unitSize.height)
        
        return CalendarPanelDayItemLayout(frame: applyingSpacing(to: frame, in: contentFrame),
                                          dayOffset: item.dayOffset,
                                          dayCount: item.dayCount)
    }
    
    /// 根据间距内缩元素视图：只内缩与页面内部相邻的边
    private func applyingSpacing(to frame: CGRect, in contentFrame: CGRect) -> CGRect {
        guard interitemSpacing > 0 else {
            return frame
        }
        
        let halfSpacing = interitemSpacing / 2.0
        var minX = frame.minX
        var maxX = frame.maxX
        var minY = frame.minY
        var maxY = frame.maxY
        
        if minX > contentFrame.minX {
            minX += halfSpacing
        }
        if maxX < contentFrame.maxX {
            maxX -= halfSpacing
        }
        if minY > contentFrame.minY {
            minY += halfSpacing
        }
        if maxY < contentFrame.maxY {
            maxY -= halfSpacing
        }
        
        return CGRect(x: minX,
                      y: minY,
                      width: max(0, maxX - minX),
                      height: max(0, maxY - minY))
    }
}
