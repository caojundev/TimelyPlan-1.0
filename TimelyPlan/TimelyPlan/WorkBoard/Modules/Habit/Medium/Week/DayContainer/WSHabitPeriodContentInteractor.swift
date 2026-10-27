//
//  WSHabitPeriodContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器基类

/// 习惯时间段组件的内容交互器基类。
///
/// 子类只需给出「取记录的时间段」与「要展示的日期」，
/// 取数、记录合并、交互与预览数据由基类统一处理。
class WSHabitPeriodContentInteractor: WSPluginContentInteractor,
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
    
    // MARK: - 子类实现
    /// 取记录使用的时间段。返回多个时记录会合并
    func fetchPeriods(containing date: Date) -> [HabitDatePeriod] {
        fatalError("Subclass must override fetchPeriods(containing:)")
    }
    
    /// 需要展示的日期，按展示顺序排列
    func displayDates(containing date: Date) -> [Date] {
        fatalError("Subclass must override displayDates(containing:)")
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = Date()
        guard let task = selectedTask() else {
            completion(nil)
            return
        }
        
        let periods = fetchPeriods(containing: date)
        let dates = displayDates(containing: date)
        fetchPeriodItem(for: task, in: periods) { periodItem in
            completion(WSHabitPeriodDataItem(periodItem: periodItem,
                                             days: WSHabitDayDataItem.items(from: periodItem, dates: dates)))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定示例，不读取用户数据
    override func previewDataItem() -> WSPluginDataItem? {
        return makePreviewDataItem(title: resGetString("Reading"),
                                   subtitle: resGetString("Check-in one time per day"),
                                   emoji: "📖",
                                   color: Color(0x5E5CE6),
                                   samples: [
                                       WSHabitPeriodPreviewSample(status: .completed, progress: 1.0),
                                       WSHabitPeriodPreviewSample(status: .inProgress, progress: 0.5),
                                       WSHabitPeriodPreviewSample(status: .notStarted),
                                       WSHabitPeriodPreviewSample(status: .skipped("😴"), reasonEmoji: "😴"),
                                       WSHabitPeriodPreviewSample(status: .failed("😖"), reasonEmoji: "😖"),
                                       WSHabitPeriodPreviewSample(status: .notStarted, isScheduled: false)
                                   ])
    }
    
    /// 生成预览数据。各天按顺序取用示例，示例不足时沿用最后一个
    func makePreviewDataItem(title: String,
                             subtitle: String,
                             emoji: String,
                             color: UIColor,
                             samples: [WSHabitPeriodPreviewSample]) -> WSPluginDataItem? {
        guard let lastSample = samples.last else {
            return nil
        }
        
        let days = displayDates(containing: Date()).enumerated().map { index, date -> WSHabitDayDataItem in
            let sample = index < samples.count ? samples[index] : lastSample
            return WSHabitDayDataItem(date: date,
                                      isScheduled: sample.isScheduled,
                                      status: sample.status,
                                      progress: sample.progress,
                                      color: color,
                                      reasonEmoji: sample.reasonEmoji)
        }
        
        return WSHabitPeriodDataItem(taskIdentifier: "preview.habit",
                                     title: title,
                                     subtitle: subtitle,
                                     icon: TPIcon(text: emoji),
                                     color: color,
                                     days: days)
    }
    
    // MARK: - 条目操作
    override func performPrimaryAction() {
        guard let task = selectedTask() else {
            return
        }
        
        let date = Date()
        let periodItem = HabitRepository.getPeriodItem(for: task, on: date)
        HabitDayMenuPresenter.showSheetMenu(for: periodItem, on: date)
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
        
        let periodItem = HabitRepository.getPeriodItem(for: task, on: date)
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
    
    /// 按标识取回当前的活动任务
    func habitTask(with identifier: String) -> HabitTask? {
        return HabitRepository.activeTasks().first { $0.identifier == identifier }
    }
    
    /// 依次取回各时间段的记录并合并到同一个条目
    private func fetchPeriodItem(for task: HabitTask,
                                 in periods: [HabitDatePeriod],
                                 completion: @escaping (HabitPeriodItem) -> Void) {
        guard let period = periods.first else {
            completion(HabitPeriodItem(habitTask: task,
                                       period: HabitDatePeriod(date: Date(), mode: .day)))
            return
        }
        
        HabitRepository.fetchPeriodItem(for: task, in: period, includeSamples: false) { [weak self] periodItem in
            guard let self = self else {
                completion(periodItem)
                return
            }
            
            self.mergePeriods(for: task,
                              remaining: Array(periods.dropFirst()),
                              into: periodItem,
                              completion: completion)
        }
    }
    
    private func mergePeriods(for task: HabitTask,
                              remaining: [HabitDatePeriod],
                              into periodItem: HabitPeriodItem,
                              completion: @escaping (HabitPeriodItem) -> Void) {
        guard let period = remaining.first else {
            completion(periodItem)
            return
        }
        
        HabitRepository.fetchPeriodItem(for: task, in: period, includeSamples: false) { [weak self] nextItem in
            if let nextRecords = nextItem.records {
                var records = periodItem.records ?? [:]
                records.merge(nextRecords) { current, _ in current }
                periodItem.records = records
            }
            
            guard let self = self else {
                completion(periodItem)
                return
            }
            
            self.mergePeriods(for: task,
                              remaining: Array(remaining.dropFirst()),
                              into: periodItem,
                              completion: completion)
        }
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

// MARK: - 预览示例

/// 预览使用的一天示例数据。
struct WSHabitPeriodPreviewSample {
    
    /// 当天状态
    let status: HabitTaskStatus
    
    /// 当天进度
    var progress: CGFloat = 0.0
    
    /// 跳过 / 失败原因 emoji
    var reasonEmoji: String? = nil
    
    /// 是否计划日
    var isScheduled: Bool = true
}
