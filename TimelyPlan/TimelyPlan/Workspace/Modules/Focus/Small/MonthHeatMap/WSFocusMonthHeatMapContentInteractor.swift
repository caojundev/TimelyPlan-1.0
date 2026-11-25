//
//  WSFocusMonthHeatMapContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation

// MARK: - 内容交互器

/// 专注·小·本月热力图的内容交互器。
///
/// 读取本月全部专注会话，按天换算热力等级后下发给内容视图；
/// 会话新增、更新、删除时重新取数，跨天刷新由基类的零点监听统一处理。
class WSFocusMonthHeatMapContentInteractor: WSPluginContentInteractor, FocusSessionProcessorDelegate {
    
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
    
    /// 仅本月新增的会话才会影响本月数据，其它日期不必刷新
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        let dateRange = monthDateRange()
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
    /// 读取本月所有会话，包含已归档计时器产生的会话
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = Date().startOfDay()
        FocusRepository.fetchSessions(dateRange: monthDateRange(), includeArchivedTimer: true) { sessions in
            completion(WSFocusMonthHeatMapDataItem(date: date, sessions: sessions ?? []))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定的一月热力分布，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        var dayLevels = [Int: Int]()
        for day in 1...28 {
            switch day % 7 {
            case 0:
                dayLevels[day] = 0
            case 1, 2:
                dayLevels[day] = 1
            case 3, 4:
                dayLevels[day] = 2
            case 5:
                dayLevels[day] = 3
            default:
                dayLevels[day] = 4
            }
        }
        
        let duration = Duration(42 * SECONDS_PER_HOUR + 30 * SECONDS_PER_MINUTE)
        return WSFocusMonthHeatMapDataItem(date: Date().startOfDay(),
                                           duration: duration,
                                           dayLevels: dayLevels)
    }
    
    /// 本月日期范围
    private func monthDateRange() -> DateRange {
        return Date().rangeOfThisMonth()
    }
}
