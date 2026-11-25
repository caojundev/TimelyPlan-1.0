//
//  WSHabitPluginContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器基类

/// 习惯组件的内容交互器基类。
///
/// 统一注册习惯数据观察者：任务、记录任意变化都重新取数；
/// 并收拢列表类组件共用的排序规则。子类只需实现取数与交互。
class WSHabitPluginContentInteractor: WSPluginContentInteractor,
                                     HabitTaskProcessorDelegate,
                                     HabitRecordProcessorDelegate {
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        HabitRepository.addUpdater(self, for: .all)
    }
    
    // MARK: - 排序
    /// 排列规则：未完成的任务排在前面，其余按任务顺序排列
    func sortedPeriodItems(_ periodItems: [HabitPeriodItem], on date: Date) -> [HabitPeriodItem] {
        return periodItems.sorted { lhs, rhs in
            let lhsCompleted = isCompleted(lhs, on: date)
            let rhsCompleted = isCompleted(rhs, on: date)
            if lhsCompleted != rhsCompleted {
                /// 未完成的排在前面
                return !lhsCompleted
            }
            
            return lhs.habitTask.order < rhs.habitTask.order
        }
    }
    
    /// 指定日期是否已完成
    func isCompleted(_ periodItem: HabitPeriodItem, on date: Date) -> Bool {
        if case .completed = periodItem.status(on: date) {
            return true
        }
        
        return false
    }
    
    // MARK: - HabitTaskProcessorDelegate
    /// 远程任务变更无法比对，保守地重新取数
    func didChangeRemoteHabitTask(with results: EntityChangeResults<HabitTask>?) {
        pluginDataDidChange()
    }
    
    func didCreateHabitTask(_ task: HabitTask) {
        pluginDataDidChange()
    }
    
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        pluginDataDidChange()
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        pluginDataDidChange()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        pluginDataDidChange()
    }
    
    /// 排序变化会影响列表顺序，统一重新取数
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        pluginDataDidChange()
    }
    
    // MARK: - HabitRecordProcessorDelegate
    func didChangeRemoteHabitRecord(with results: EntityChangeResults<HabitRecord>?) {
        pluginDataDidChange()
    }
    
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        pluginDataDidChange()
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        pluginDataDidChange()
    }
}
