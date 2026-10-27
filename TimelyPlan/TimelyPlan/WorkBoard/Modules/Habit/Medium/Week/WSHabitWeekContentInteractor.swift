//
//  WSHabitWeekContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器

/// 习惯·中·周进度的内容交互器。
/// 跨周刷新由基类的零点监听统一处理。
class WSHabitWeekContentInteractor: WSPluginContentInteractor,
                                   HabitTaskProcessorDelegate,
                                   HabitRecordProcessorDelegate {
    
    /// 配置中选择的习惯任务标识
    private var selectedTaskIdentifier: String? {
        return plugin.configuration(as: WSHabitSelectedConfiguration.self)?.taskIdentifier
    }
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 观察者由数据仓库弱引用持有，无需手动移除
        HabitRepository.addUpdater(self, for: .all)
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let task = selectedTask() else {
            completion(nil)
            return
        }
        
        HabitRepository.fetchPeriodItem(for: task,
                                        in: weekPeriod(containing: .now),
                                        includeSamples: false) { periodItem in
            completion(WSHabitPeriodDataItem(periodItem: periodItem))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定示例，不读取用户数据
    override func previewDataItem() -> WSPluginDataItem? {
        let samples: [(status: HabitTaskStatus, progress: CGFloat, emoji: String?, isScheduled: Bool)] = [
            (.completed, 1.0, nil, true),
            (.completed, 1.0, nil, true),
            (.inProgress, 0.5, nil, true),
            (.notStarted, 0.0, nil, true),
            (.skipped("😴"), 0.0, "😴", true),
            (.failed("😖"), 0.0, "😖", true),
            (.notStarted, 0.0, nil, false)
        ]
        
        let color = Color(0xFF9F0A)
        let dates = weekPeriod(containing: Date()).weekDaysPeriods().map { $0.date }
        let days = dates.enumerated().map { index, date -> WSHabitDayDataItem in
            let sample = samples[min(index, samples.count - 1)]
            return WSHabitDayDataItem(date: date,
                                      isScheduled: sample.isScheduled,
                                      status: sample.status,
                                      progress: sample.progress,
                                      color: color,
                                      reasonEmoji: sample.emoji)
        }
        
        return WSHabitPeriodDataItem(taskIdentifier: "preview.habit",
                                   title: resGetString("Reading"),
                                   subtitle: resGetString("Check-in one time per day"),
                                   icon: TPIcon(text: "📖"),
                                   color: color,
                                   days: days)
    }
    
    // MARK: - 条目操作
    /// 点击任务信息区域：打开该习惯的统计页
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let dataItem = dataItem as? WSHabitPeriodDataItem,
              let task = habitTask(with: dataItem.taskIdentifier) else {
            return
        }
        
        HabitPresenter.showStats(for: task, date: .now)
    }
    
    /// 点击某一天：与习惯首页周视图一致，计划日打开只处理记录的菜单
    func showDayMenu(for dayItem: WSHabitDayDataItem) {
        TPImpactFeedback.impactWithSoftStyle()
        
        let date = dayItem.date
        guard dayItem.isScheduled else {
            HabitPresenter.showNotScheduledDayMessage(for: date)
            return
        }
        
        guard let task = selectedTask() else {
            return
        }
        
        let periodItem = HabitPeriodItemFetcher().getPeriodItem(for: task,
                                                                in: weekPeriod(containing: date),
                                                                includeSamples: false)
        HabitDayMenuPresenter.showPopoverMenu(for: periodItem,
                                              on: date,
                                              menuType: .recordOnly)
    }
    
    // MARK: - 数据
    private func selectedTask() -> HabitTask? {
        guard let identifier = selectedTaskIdentifier else {
            return nil
        }

        return HabitRepository.getTask(with: identifier)
    }
    
    /// 日期所在周的时间段
    private func weekPeriod(containing date: Date) -> HabitDatePeriod {
        return HabitDatePeriod(date: date,
                               mode: .week,
                               firstWeekday: HabitSetting.shared.firstWeekday)
    }
    
    /// 按标识取回当前的活动任务
    private func habitTask(with identifier: String) -> HabitTask? {
        return HabitRepository.activeTasks().first { $0.identifier == identifier }
    }
    
    // MARK: - HabitTaskProcessorDelegate
    /// 远程变更无法比对标识，保守地重新取数
    func didChangeRemoteHabitTask(with results: EntityChangeResults<HabitTask>?) {
        pluginDataDidChange()
    }
    
    func didUpdateHabitTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        guard task.identifier == selectedTaskIdentifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        guard task.identifier == selectedTaskIdentifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        guard task.identifier == selectedTaskIdentifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    /// 排序变化会影响未配置时的默认选择，统一重新取数
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
        guard task.identifier == selectedTaskIdentifier else {
            return
        }
        
        pluginDataDidChange()
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        guard let task = task, task.identifier == selectedTaskIdentifier else {
            return
        }
        
        pluginDataDidChange()
    }
}
