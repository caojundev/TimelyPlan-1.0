//
//  WSCalendarTodayDateContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·今日日期的内容交互器。
///
/// 每天零点跨天时重新取数，应用回到前台或系统日期变化时也会补一次校验。
class WSCalendarTodayDateContentInteractor: WSPluginContentInteractor {

    /// 上次取数对应的当日零点
    private var loadedDay: Date?

    private var observers: [NSObjectProtocol] = []

    /// 对齐到下一个零点的定时器
    private var dayTimer: Timer?

    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)

        let names: [Notification.Name] = [
            UIApplication.didBecomeActiveNotification,
            UIApplication.significantTimeChangeNotification,
        ]
        let center = NotificationCenter.default
        observers = names.map { name in
            return center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.checkDayChange()
            }
        }
        scheduleMidnightTimer()
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        dayTimer?.invalidate()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        completion(makeTodayDataItem())
    }

    override func previewDataItem() -> WSPluginDataItem? {
        return makeTodayDataItem()
    }

    // MARK: - 零点更新
    override func updateAtMidnight() {
        checkDayChange()
    }

    private func checkDayChange() {
        reloadIfDayChanged()
        scheduleMidnightTimer()
    }

    /// 定时器对齐到下一个零点，避免仅依赖系统通知时遗漏前台跨天
    private func scheduleMidnightTimer() {
        dayTimer?.invalidate()
        let interval = max(Date().endOfDay().timeIntervalSinceNow + 1.0, 1.0)
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            self?.checkDayChange()
        }
        dayTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func makeTodayDataItem() -> WSCalendarTodayDateDataItem {
        let now = Date()
        loadedDay = now.startOfDay()
        return WSCalendarTodayDateDataItem(date: now)
    }

    private func reloadIfDayChanged() {
        guard loadedDay != Date.startOfToday else {
            return
        }

        setNeedsReload()
    }
}
