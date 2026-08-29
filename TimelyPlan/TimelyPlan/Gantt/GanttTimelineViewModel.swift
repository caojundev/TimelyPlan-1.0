//
//  GanttTimelineViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/28.
//

import Foundation

/// 甘特图时间线视图模型
///
/// 职责：
/// - 加载指定 range（DateInterval）范围内的 GanttEvents
/// - 通过 GanttEventChangeDelegate 监听事项变更，当变更影响当前 range 时自动重新加载，
///   并通过 `onEventsChanged` 通知外部（如 ViewController）刷新视图
class GanttTimelineViewModel: GanttEventChangeDelegate {

    /// 当前 range 内事项改变回调（外部在此更新 UI）
    var onEventsChanged: (() -> Void)?

    /// 当前加载的日期范围
    private(set) var range: DateInterval?

    /// 当前范围内的事项
    private(set) var events: [GanttEvent]?

    /// 请求竞态管理器（防止旧请求覆盖新请求结果）
    private let requestManager = TPRequestManager()

    /// 数据仓库
    private let repository: GanttRepository

    /// 加载状态
    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            self.placeholderProvider.state = state
        }
    }

    /// 占位视图提供者（加载中 / 空）
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()

    init() {
        self.placeholderProvider.state = state
        self.repository = GanttRepository()
        self.repository.addUpdaterDelegate(self)
    }

    deinit {
        repository.removeUpdaterDelegate(self)
    }

    /// 重新加载当前 range 内的事项
    func refresh() {
        guard let range = range else {
            return
        }

        loadEvents(in: range)
    }

    /// 加载指定 range 内的事项
    ///
    /// - Parameter range: 目标日期范围
    func loadEvents(in range: DateInterval) {
        self.range = range
        let requestID = requestManager.executeRequest()
        self.state = .loading

        repository.fetchEvents(in: range) { [weak self] events in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            self.state = .loaded
            self.events = events
            self.onEventsChanged?()
        }
    }

    // MARK: - GanttEventChangeDelegate

    func ganttEventsDidChange(in ranges: [DateInterval]) {
        guard let currentRange = self.range else {
            return
        }

        var shouldReload = false
        for changedRange in ranges {
            if currentRange.intersects(changedRange) {
                shouldReload = true
                break
            }
        }

        if shouldReload {
            loadEvents(in: currentRange)
        }
    }
}
