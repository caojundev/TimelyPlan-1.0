//
//  WSFocusTodayComparisonContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation

// MARK: - 内容交互器

/// 专注·小·今日对比的内容交互器。
///
/// 一次取数覆盖昨日与今日，按日期拆分后下发给内容视图；
/// 会话新增、更新、删除时重新取数，跨天刷新由基类的零点监听统一处理。
class WSFocusTodayComparisonContentInteractor: WSPluginContentInteractor, FocusSessionProcessorDelegate {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        FocusRepository.addUpdater(self, for: [.session])
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didChangeRemoteFocusSession(with results: EntityChangeResults<FocusSession>?) {
        pluginDataDidChange()
    }
    
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        pluginDataDidChange()
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        pluginDataDidChange()
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        pluginDataDidChange()
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let today = Date().startOfDay()
        guard let yesterday = today.dateByAddingDays(-1) else {
            completion(nil)
            return
        }
        
        let dateRange = DateRange(startDate: yesterday, endDate: Date().endOfDay())
        FocusRepository.fetchSessions(dateRange: dateRange, includeArchivedTimer: true) { sessions in
            let sessions = sessions ?? []
            let todaySessions = sessions.filter { $0.startDate?.isInSameDayAs(today) ?? false }
            let yesterdaySessions = sessions.filter { $0.startDate?.isInSameDayAs(yesterday) ?? false }
            
            completion(WSFocusTodayComparisonDataItem(today: todaySessions.duration,
                                                      yesterday: yesterdaySessions.duration))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：今日 9 小时 41 分钟，昨日 4 小时
    override func previewDataItem() -> WSPluginDataItem? {
        let today = Duration(9 * SECONDS_PER_HOUR + 41 * SECONDS_PER_MINUTE)
        let yesterday = Duration(4 * SECONDS_PER_HOUR)
        return WSFocusTodayComparisonDataItem(today: today, yesterday: yesterday)
    }
}
