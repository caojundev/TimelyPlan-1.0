//
//  WSFocusTodayActivityContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation

// MARK: - 内容交互器

/// 专注·小·今日活动的内容交互器。
///
/// 读取当日全部专注会话，换算成 `FocusStatsDayInfo` 后下发给内容视图；
/// 会话新增、更新、删除时重新取数，跨天刷新由基类的零点监听统一处理。
class WSFocusTodayActivityContentInteractor: WSPluginContentInteractor, FocusSessionProcessorDelegate {
    
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
    
    /// 仅今日新增的会话才会影响今日数据，其它日期不必刷新
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        let today = Date()
        guard sessions.contains(where: { $0.startDate?.isInSameDayAs(today) ?? false }) else {
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
    /// 读取当日所有会话，包含已归档计时器产生的会话
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = Date().startOfDay()
        FocusRepository.fetchSessions(for: date, includeArchivedTimer: true) { sessions in
            let dayInfo = FocusStatsDayInfo(date: date, sessions: sessions ?? [])
            completion(WSFocusTodayActivityDataItem(dayInfo: dayInfo))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定的一天活动分布，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let hourlyActivity: [Int: Float] = [
            7: 0.35,
            8: 1.0,
            9: 0.85,
            10: 0.5,
            14: 0.7,
            15: 1.0,
            16: 0.9,
            20: 0.45
        ]
        
        /// 时长与柱线分布保持一致：5 小时 45 分钟
        let duration = Duration(5 * SECONDS_PER_HOUR + 45 * SECONDS_PER_MINUTE)
        return WSFocusTodayActivityDataItem(date: Date().startOfDay(),
                                            duration: duration,
                                            times: 6,
                                            hourlyActivity: hourlyActivity)
    }
}
