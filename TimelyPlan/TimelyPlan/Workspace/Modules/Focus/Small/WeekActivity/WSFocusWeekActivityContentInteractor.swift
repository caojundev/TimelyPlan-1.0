//
//  WSFocusWeekActivityContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation

// MARK: - 内容交互器

/// 专注·小·本周活动的内容交互器。
///
/// 读取本周全部专注会话，按天汇总后下发给内容视图；
/// 会话新增、更新、删除时重新取数，跨天刷新由基类的零点监听统一处理。
class WSFocusWeekActivityContentInteractor: WSPluginContentInteractor, FocusSessionProcessorDelegate {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        FocusRepository.addUpdater(self, for: [.session])
    }
    
    // MARK: - FocusSessionProcessorDelegate
    /// 远程专注会话改变，重新取数并通知内容视图刷新
    func didChangeRemoteFocusSession(with results: EntityChangeResults<FocusSession>?) {
        pluginDataDidChange()
    }
    
    /// 仅本周新增的会话才会影响本周数据，其它日期不必刷新
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        let dateRange = weekDateRange()
        guard sessions.contains(where: { session in
            guard let date = session.startDate else { return false }
            return dateRange.contains(date: date)
        }) else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        pluginDataDidChange()
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        pluginDataDidChange()
    }
    
    // MARK: - 取数
    /// 读取本周所有会话，包含已归档计时器产生的会话
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let dateRange = weekDateRange()
        FocusRepository.fetchSessions(dateRange: dateRange, includeArchivedTimer: true) { sessions in
            completion(WSFocusWeekActivityDataItem(dateRange: dateRange, sessions: sessions ?? []))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定的一周活动分布，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let startDate = Date().firstDayOfWeek()
        let endDate = startDate.dateByAddingDays(DAYS_PER_WEEK - 1) ?? startDate
        let dailyActivity: [Float] = [0.45, 0.6, 0.75, 1.0, 0.55, 0.85, 0.3]
        
        /// 时长与柱条分布保持一致：最长一天 3.5 小时
        let duration = Duration(15 * SECONDS_PER_HOUR + 30 * SECONDS_PER_MINUTE)
        return WSFocusWeekActivityDataItem(startDate: startDate,
                                           endDate: endDate,
                                           duration: duration,
                                           times: 20,
                                           dailyActivity: dailyActivity)
    }
    
    /// 本周日期范围
    private func weekDateRange() -> DateRange {
        return Date().rangeOfThisWeek(firstWeekday: Weekday.firstWeekday)
    }
}
