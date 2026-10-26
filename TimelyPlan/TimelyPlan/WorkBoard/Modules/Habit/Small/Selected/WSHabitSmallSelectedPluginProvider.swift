//
//  WSHabitSmallSelectedPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 配置

/// 习惯·小·自选的配置
struct WSHabitSelectedConfiguration: Codable {
    
    /// 用户选择的习惯任务标识
    var taskIdentifier: String?
}

// MARK: - 组件提供者

/// 习惯·小·自选。展示用户自己选择的一个习惯任务。
class WSHabitSmallSelectedPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .habitSmallSelected
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return .small
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSHabitSmallSelectedContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHabitSelectedContentInteractor(plugin: plugin, context: context)
    }
    
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSHabitSmallSelectedConfigViewController(plugin: plugin)
    }
    
    /// 未选择习惯时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Habit Selected")
        return configuration
    }
}

// MARK: - 内容交互器

class WSHabitSelectedContentInteractor: WSPluginContentInteractor,
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
        guard let identifier = selectedTaskIdentifier,
              let task = HabitRepository.activeTasks().first(where: { $0.identifier == identifier }) else {
            completion(nil)
            return
        }
        
        let period = HabitDatePeriod(date: Date(), mode: .day)
        HabitRepository.fetchPeriodItem(for: task, in: period, includeSamples: false) { periodItem in
            completion(WSHabitTaskDataItem(periodItem: periodItem))
        }
    }
    
    // MARK: - 主操作
    /// 点击组件：打开所选习惯的当日操作菜单
    override func performPrimaryAction() {
        guard let dataItem = dataItem as? WSHabitTaskDataItem,
              let task = HabitRepository.activeTasks().first(where: { $0.identifier == dataItem.taskIdentifier }) else {
            return
        }
        
        let periodItem = HabitRepository.getPeriodItem(for: task, on: dataItem.date)
        HabitDayMenuPresenter.showSheetMenu(for: periodItem, on: dataItem.date)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一个示例习惯，不受用户配置影响
    override func previewDataItem() -> WSPluginDataItem? {
        return WSHabitTaskDataItem(taskIdentifier: "preview.habit",
                                   date: Date(),
                                   title: resGetString("Reading"),
                                   subtitle: "1/3 \(resGetString("Times"))",
                                   color: Color(0xFF9F0A),
                                   icon: TPIcon(text: "📖"),
                                   progress: 1.0 / 3.0,
                                   status: .inProgress)
    }
    
    // MARK: - HabitTaskProcessorDelegate
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
