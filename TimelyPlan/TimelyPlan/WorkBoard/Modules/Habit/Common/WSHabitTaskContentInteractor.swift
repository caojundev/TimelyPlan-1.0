//
//  WSHabitTaskContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation

// MARK: - 内容交互器

/// 习惯任务组件的内容交互器。
///
/// 与习惯首页一致，读取今日排期的习惯任务（当日记录一并取出），
/// 换算成行数据后下发；任务与记录变化时重新取数，跨天刷新由基类的零点监听统一处理。
class WSHabitTaskContentInteractor: WSPluginContentInteractor,
                                    HabitTaskProcessorDelegate,
                                    HabitRecordProcessorDelegate {
    
    /// 最多展示的习惯任务数目
    private let maximumItemCount: Int
    
    init(plugin: WSPlugin, context: WSPluginContext, maximumItemCount: Int) {
        self.maximumItemCount = maximumItemCount
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        HabitRepository.addUpdater(self, for: .all)
    }
    
    // MARK: - HabitTaskProcessorDelegate
    /// 习惯任务数据发生变化，重新取数并通知内容视图刷新
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
    
    // MARK: - 取数
    /// 读取今日排期的习惯任务，未完成的优先，取前若干个
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = Date()
        HabitRepository.fetchScheduledPeriodItems(on: date, includeSamples: false) { [weak self] periodItems in
            guard let self = self else {
                completion(nil)
                return
            }
            
            let periodItems = self.sortedPeriodItems(from: periodItems ?? [])
            guard !periodItems.isEmpty else {
                /// 没有可展示的任务时交给空白内容视图
                completion(nil)
                return
            }
            
            let items = periodItems.prefix(self.maximumItemCount).map { WSHabitTaskDataItem(periodItem: $0) }
            completion(WSHabitTasksDataItem(items: items))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示几个示例习惯，不受用户数据影响，条数与真实展示一致
    override func previewDataItem() -> WSPluginDataItem? {
        let examples: [WSHabitTaskPreview] = [
            WSHabitTaskPreview(title: resGetString("Workout"),
                               emoji: "🏃",
                               colorHex: 0xFF375F,
                               completed: 3,
                               target: 3,
                               status: .completed),
            WSHabitTaskPreview(title: resGetString("Meditation"),
                               emoji: "🧘",
                               colorHex: 0xAF52DE,
                               completed: 0,
                               target: 2,
                               status: .notStarted),
            WSHabitTaskPreview(title: resGetString("Study"),
                               emoji: "📚",
                               colorHex: 0x0A84FF,
                               completed: 1,
                               target: 2,
                               status: .inProgress),
            WSHabitTaskPreview(title: resGetString("Deep Work"),
                               emoji: "🧠",
                               colorHex: 0x5E5CE6,
                               completed: 3,
                               target: 4,
                               status: .inProgress),
            WSHabitTaskPreview(title: resGetString("Planning"),
                               emoji: "🗓",
                               colorHex: 0xFF9500,
                               completed: 0,
                               target: 1,
                               status: .notStarted),
            WSHabitTaskPreview(title: resGetString("Reading"),
                               emoji: "📖",
                               colorHex: 0xFF9F0A,
                               completed: 1,
                               target: 1,
                               status: .completed),
            WSHabitTaskPreview(title: resGetString("Writing"),
                               emoji: "✍️",
                               colorHex: 0x34C759,
                               completed: 1,
                               target: 2,
                               status: .inProgress),
            WSHabitTaskPreview(title: resGetString("Coffee Break"),
                               emoji: "☕️",
                               colorHex: 0x8E8E93,
                               completed: 1,
                               target: 1,
                               status: .completed)
        ]
        
        let date = Date()
        let items: [WSHabitTaskDataItem] = examples.prefix(maximumItemCount).map { example -> WSHabitTaskDataItem in
            let subtitle = "\(example.completed)/\(example.target) \(resGetString("Times"))"
            return WSHabitTaskDataItem(taskIdentifier: "preview.\(example.title)",
                                       date: date,
                                       title: example.title,
                                       subtitle: subtitle,
                                       color: Color(example.colorHex),
                                       icon: TPIcon(text: example.emoji),
                                       progress: CGFloat(example.completed) / CGFloat(max(example.target, 1)),
                                       status: example.status)
        }
        
        return WSHabitTasksDataItem(items: items)
    }
    
    // MARK: - 主操作
    /// 点击习惯任务：打开该习惯动作菜单
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSHabitTaskDataItem,
              let task = HabitRepository.getTask(with: dataItem.taskIdentifier) else {
            return
        }
        
        let date = dataItem.date
        let periodItem = HabitRepository.getPeriodItem(for: task, on: date)
        HabitDayMenuPresenter.showSheetMenu(for: periodItem, on: date)
    }
    
    // MARK: - 数据
    /// 排列规则：未完成的任务排在前面，其余按任务顺序排列
    private func sortedPeriodItems(from periodItems: [HabitPeriodItem]) -> [HabitPeriodItem] {
        return periodItems.sorted { lhs, rhs in
            let lhsCompleted = isCompleted(lhs)
            let rhsCompleted = isCompleted(rhs)
            if lhsCompleted != rhsCompleted {
                /// 未完成的排在前面
                return !lhsCompleted
            }
            
            return lhs.habitTask.order < rhs.habitTask.order
        }
    }
    
    /// 当日是否已完成
    private func isCompleted(_ periodItem: HabitPeriodItem) -> Bool {
        if case .completed = periodItem.status(on: periodItem.period.date) {
            return true
        }
        
        return false
    }
}

// MARK: - 预览示例

/// 画廊预览使用的示例习惯。
private struct WSHabitTaskPreview {
    
    /// 示例名称
    let title: String
    
    /// 示例图标
    let emoji: String
    
    /// 示例颜色
    let colorHex: UInt64
    
    /// 已完成量
    let completed: Int
    
    /// 目标量
    let target: Int
    
    /// 任务状态
    let status: HabitTaskStatus
}
