//
//  CalendarPanelStyle.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/29.
//

import Foundation
import UIKit

/// 日历面板布局样式
enum CalendarPanelStyle: String, CaseIterable, Codable {
    case fourPlusFourHorizontal
    case fourPlusFourVertical
    case threePlusFourVertical
    case fivePlusTwoTwoColumn
    case onePlusSixTwoColumn
    case sixPlusOneTwoColumn
    
    /// UI 上显示的名称
    var displayName: String {
        switch self {
        case .fourPlusFourHorizontal:
            return resGetString("4 + 4 (Horizontal)")
        case .fourPlusFourVertical:
            return resGetString("4 + 4 (Vertical)")
        case .threePlusFourVertical:
            return resGetString("3 + 4 (Vertical)")
        case .fivePlusTwoTwoColumn:
            return resGetString("5 + 2 (Two Columns)")
        case .onePlusSixTwoColumn:
            return resGetString("1 + 6")
        case .sixPlusOneTwoColumn:
            return resGetString("6 + 1")
        }
    }
    
    var iconName: String {
        switch self {
        case .fourPlusFourHorizontal:
            return "calnedar_panelStyle_4_4_horizontal"
        case .fourPlusFourVertical:
            return "calnedar_panelStyle_4_4_vertical"
        case .threePlusFourVertical:
            return "calendar_panelStyle_3_4_vertical"
        case .fivePlusTwoTwoColumn:
            return "calnedar_panelStyle_5_2_twoColumn"
        case .onePlusSixTwoColumn:
            return "calnedar_panelStyle_1_6"
        case .sixPlusOneTwoColumn:
            return "calnedar_panelStyle_6_1"
        }
    }
}

// MARK: - 布局配置

/// 页面的网格划分：把页面按行、列各分成若干块，天元素视图按块坐标定位
struct CalendarPanelGrid {
    /// 行块数
    let rows: Int
    /// 列块数
    let columns: Int
}

/// 天元素视图的配置：一个元素视图可以只显示一天，也可以显示连续的若干天
struct CalendarPanelDayItemConfig {
    /// 起始天在页面中的偏移（相对页面第一天，从 0 开始）
    let dayOffset: Int
    /// 显示的天数：1 为单天视图，大于 1 为多天视图
    let dayCount: Int
    /// 在网格中的位置（块坐标）
    let row: Int
    let column: Int
    /// 占用的网格块数
    let rowSpan: Int
    let columnSpan: Int
}

/// 天条目配置元组
/// - dayOffset: 起始天在页面中的偏移（相对页面第一天，从 0 开始）
/// - dayCount: 显示的天数，1 为单天视图，大于 1 为多天视图
/// - row / column: 在网格中的起始块坐标
/// - rowSpan / columnSpan: 占用的网格块数
typealias CalendarPanelDayItemTuple = (dayOffset: Int,
                                       dayCount: Int,
                                       row: Int,
                                       column: Int,
                                       rowSpan: Int,
                                       columnSpan: Int)

/// 挂件配置：非天元素视图（如月历小视图）在页面中占用的网格块
struct CalendarPanelWidgetConfig {
    /// 在网格中的位置（块坐标）
    let row: Int
    let column: Int
    /// 占用的网格块数
    let rowSpan: Int
    let columnSpan: Int
}

/// 挂件配置元组
/// - row / column: 在网格中的起始块坐标
/// - rowSpan / columnSpan: 占用的网格块数
typealias CalendarPanelWidgetTuple = (row: Int,
                                      column: Int,
                                      rowSpan: Int,
                                      columnSpan: Int)

/// 单个样式的布局配置
struct CalendarPanelLayoutConfig {
    
    /// 网格划分
    let grid: CalendarPanelGrid
    
    /// 页面中的所有天元素视图
    let dayItems: [CalendarPanelDayItemConfig]
    
    /// 页面中的挂件（非天元素视图，如 4 + 4 左上角的月历小视图）
    let widgets: [CalendarPanelWidgetConfig]
    
    /// 页面显示的总天数
    var daysInPage: Int {
        return dayItems.reduce(0) { max($0, $1.dayOffset + $1.dayCount) }
    }
    
    // MARK: - Init
    
    /// 根据样式初始化布局配置
    /// 每个样式只需列出所有天条目与挂件的配置元组，顺序即为视图的顺序
    init(style: CalendarPanelStyle) {
        // (天偏移, 天数, 行, 列, 行块数, 列块数)
        let tuples: [CalendarPanelDayItemTuple]
        // (行, 列, 行块数, 列块数)
        let widgetTuples: [CalendarPanelWidgetTuple]
        
        switch style {
        case .threePlusFourVertical:
            // 2 列 12 行：左列从上到下为第 1~3 天（每天占 4 行），右列从上到下为第 4~7 天（每天占 3 行）
            tuples = [(0, 1, 0, 0, 4, 1),
                      (1, 1, 4, 0, 4, 1),
                      (2, 1, 8, 0, 4, 1),
                      (3, 1, 0, 1, 3, 1),
                      (4, 1, 3, 1, 3, 1),
                      (5, 1, 6, 1, 3, 1),
                      (6, 1, 9, 1, 3, 1)]
            widgetTuples = []
            
        case .fourPlusFourHorizontal:
            // 2 列 4 行：左上角为月历挂件（1 x 1 块），第二列显示第 1 天；第二至四行每行一个元素视图、各显示 2 天
            tuples = [(0, 1, 0, 1, 1, 1),
                      (1, 2, 1, 0, 1, 2),
                      (3, 2, 2, 0, 1, 2),
                      (5, 2, 3, 0, 1, 2)]
            widgetTuples = [(0, 0, 1, 1)]
            
        case .fourPlusFourVertical:
            // 2 列 4 行：左上角为月历挂件（1 x 1 块），左列自上而下为第 1~3 天，右列自上而下为第 4~7 天
            tuples = [(0, 1, 1, 0, 1, 1),
                      (1, 1, 2, 0, 1, 1),
                      (2, 1, 3, 0, 1, 1),
                      (3, 1, 0, 1, 1, 1),
                      (4, 1, 1, 1, 1, 1),
                      (5, 1, 2, 1, 1, 1),
                      (6, 1, 3, 1, 1, 1)]
            widgetTuples = [(0, 0, 1, 1)]

        case .fivePlusTwoTwoColumn:
            // 2 列 10 行：左列从上到下为第 1~5 天（每天占 2 行），右列从上到下为第 6~7 天（每天占 5 行）
            tuples = [(0, 1, 0, 0, 2, 1),
                      (1, 1, 2, 0, 2, 1),
                      (2, 1, 4, 0, 2, 1),
                      (3, 1, 6, 0, 2, 1),
                      (4, 1, 8, 0, 2, 1),
                      (5, 1, 0, 1, 5, 1),
                      (6, 1, 5, 1, 5, 1)]
            widgetTuples = []
            
        case .onePlusSixTwoColumn:
            tuples = [(0, 1, 0, 0, 1, 2),
                      (1, 2, 1, 0, 1, 2),
                      (3, 2, 2, 0, 1, 2),
                      (5, 2, 3, 0, 1, 2)]
            widgetTuples = []
            
        case .sixPlusOneTwoColumn:
            // 2 列 4 行：前三行每行 2 天（第 1~6 天），最后一行为第 7 天、占满整行
            tuples = [(0, 2, 0, 0, 1, 2),
                      (2, 2, 1, 0, 1, 2),
                      (4, 2, 2, 0, 1, 2),
                      (6, 1, 3, 0, 1, 2)]
            widgetTuples = []
        }
        
        self.init(tuples: tuples, widgetTuples: widgetTuples)
    }
    
    // MARK: - 天条目/挂件元组
    
    /// 根据天条目与挂件的配置元组生成布局配置
    /// - Parameters:
    ///   - tuples: 天条目元组数组，顺序即为天元素视图的顺序
    ///   - widgetTuples: 挂件元组数组，顺序即为挂件的顺序
    ///                   网格尺寸由所有元组占用的最大行数、列数自动推导
    private init(tuples: [CalendarPanelDayItemTuple],
                 widgetTuples: [CalendarPanelWidgetTuple]) {
        self.dayItems = tuples.map {
            CalendarPanelDayItemConfig(dayOffset: $0.dayOffset,
                                       dayCount: $0.dayCount,
                                       row: $0.row,
                                       column: $0.column,
                                       rowSpan: $0.rowSpan,
                                       columnSpan: $0.columnSpan)
        }
        
        self.widgets = widgetTuples.map {
            CalendarPanelWidgetConfig(row: $0.row,
                                      column: $0.column,
                                      rowSpan: $0.rowSpan,
                                      columnSpan: $0.columnSpan)
        }
        
        let rowOffsets = tuples.map { $0.row + $0.rowSpan } + widgetTuples.map { $0.row + $0.rowSpan }
        let columnOffsets = tuples.map { $0.column + $0.columnSpan } + widgetTuples.map { $0.column + $0.columnSpan }
        self.grid = CalendarPanelGrid(rows: rowOffsets.max() ?? 0,
                                      columns: columnOffsets.max() ?? 0)
    }
}
