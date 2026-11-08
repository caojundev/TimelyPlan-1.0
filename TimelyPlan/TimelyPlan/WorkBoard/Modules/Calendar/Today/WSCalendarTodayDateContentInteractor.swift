//
//  WSCalendarTodayDateContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

/// 日历·小·今日日期的内容交互器。
///
/// 只负责提供今天的日期；点击组件打开今天的事项列表并可添加事项，由基类统一处理。
class WSCalendarTodayDateContentInteractor: WSCalendarEventContentInteractor {

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        completion(WSCalendarTodayDateDataItem(date: Date()))
    }

    override func previewDataItem() -> WSPluginDataItem? {
        return WSCalendarTodayDateDataItem(date: Date())
    }
}
