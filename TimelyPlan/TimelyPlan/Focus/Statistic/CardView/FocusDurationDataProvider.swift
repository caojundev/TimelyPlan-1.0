//
//  FocusDurationDataProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation

/// 专注时长数据提供者
///
/// 遵照该协议的对象负责异步获取指定日期范围内的统计数据，
/// 交由 `FocusDurationChartContainerView` 解析为柱状图数据并绘制。
protocol FocusDurationDataProvider: AnyObject {

    /// 专注会话变化回调（新增 / 更新 / 删除），参数为发生变化的会话时间区间
    var onSessionChanged: (([DateInterval]) -> Void)? { get set }

    /// 异步获取统计数据
    /// - Parameters:
    ///   - dateRange: 统计日期范围
    ///   - completion: 数据回调
    func fetchFocusStatsDataItem(dateRange: DateRange,
                                 completion: @escaping (FocusStatsDataItem) -> Void)
}
