//
//  GoalRecordListViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/9.
//

import Foundation
import UIKit

/// 目标记录列表展示模型：用于渲染单条记录的一行。
struct GoalRecordRowPresentation {
    
    /// 记录唯一标识（用于删除等操作）
    let identifier: String
    
    /// 记录时间文本（如 "14:30"）
    let time: String
    
    /// 记录原始数值（变化量，增加为正、减少为负）
    let amount: Int64
    
    /// 记录数值文本（带符号，如 "+5" / "-3" / "0"）
    let amountText: String
    
    /// 备注（无备注时为 nil）
    let note: String?
}

/// 一天的目标记录分组。
struct GoalRecordDayGroup {
    
    /// 所属日期
    let date: Date
    
    /// 区块标题（今天 / 昨天 / 9月5日 周六）
    let title: String
    
    /// 当天的记录展示模型（按时间倒序，最新在前）
    let rows: [GoalRecordRowPresentation]
}

/// 目标记录列表 ViewModel
///
/// 负责获取目标任务的全部记录并将其「按天分组」，
/// 同时监听目标记录的变化，在增删改后自动刷新。
final class GoalRecordListViewModel: GoalRecordProcessorDelegate {
    
    /// 目标任务
    let task: GoalTask
    
    /// 当前任务的全部记录（原始数据）
    private var records: [GoalRecord] = []
    
    /// 按天分组后的数据（倒序，最新的一天在前）
    private(set) var dayGroups: [GoalRecordDayGroup] = []
    
    /// 数据刷新回调（供视图控制器重建界面）
    var didChangeRecords: (() -> Void)?
    
    init(task: GoalTask) {
        self.task = task
        GoalRepository.addUpdater(self, for: [.record])
    }
    
    deinit {
        GoalRepository.removeUpdater(self)
    }
    
    // MARK: - 加载数据
    
    /// 获取记录并按天分组
    func reload() {
        let records = GoalRepository.getRecords(for: task)
        self.records = records
        self.dayGroups = GoalRecordListViewModel.dayGroups(from: records)
        self.didChangeRecords?()
    }
    
    // MARK: - 删除
    
    /// 删除指定标识的单条记录
    /// - Parameter identifier: 记录标识
    func deleteRecord(withIdentifier identifier: String) {
        guard let record = records.first(where: { $0.identifier == identifier }) else {
            return
        }
        
        GoalRepository.deleteRecord(record, for: task)
        /// 删除成功后由更新器回调触发 reload
    }
    
    // MARK: - 更新
    
    /// 更新指定标识记录的数值与备注
    /// - Parameters:
    ///   - identifier: 记录标识
    ///   - amount: 新的数值（变化量，增加为正、减少为负）
    ///   - note: 新的备注（传 nil 表示清空）
    func updateRecord(withIdentifier identifier: String,
                      amount: Int64,
                      note: String?) {
        guard let record = records.first(where: { $0.identifier == identifier }) else {
            return
        }
        
        GoalRepository.updateRecord(record, amount: amount, note: note, for: task)
        /// 更新成功后由更新器回调触发 reload
    }
    
    /// 将记录按天分组并排序
    static func dayGroups(from records: [GoalRecord]) -> [GoalRecordDayGroup] {
        var grouped: [Int32: [GoalRecord]] = [:]
        for record in records {
            guard let day = record.day else {
                continue
            }
            
            grouped[day, default: []].append(record)
        }
        
        /// 天按倒序排列（最新的一天在前）
        let sortedDays = grouped.keys.sorted(by: >)
        var result: [GoalRecordDayGroup] = []
        for day in sortedDays {
            guard let date = Date.dateFromDayIntegerKey(day),
                  let dayRecords = grouped[day] else {
                continue
            }
            
            /// 当天记录按时间倒序排列
            let rows = GoalRecordListViewModel.rows(from: dayRecords)
            let group = GoalRecordDayGroup(date: date,
                                           title: GoalRecordListViewModel.title(for: date),
                                           rows: rows)
            result.append(group)
        }
        
        return result
    }
    
    /// 生成一天的记录展示模型
    static func rows(from records: [GoalRecord]) -> [GoalRecordRowPresentation] {
        let sorted = records.sorted { lhs, rhs in
            return (lhs.date ?? .distantPast) > (rhs.date ?? .distantPast)
        }
        
        return sorted.map { record in
            let amount = record.amount
            var amountText = "\(amount)"
            if amount > 0 {
                amountText = "+\(amount)"
            }
            
            return GoalRecordRowPresentation(identifier: record.identifier,
                                             time: record.date?.timeString ?? "",
                                             amount: amount,
                                             amountText: amountText,
                                             note: record.hasNote ? record.note : nil)
        }
    }
    
    /// 区块标题
    static func title(for date: Date) -> String {
        if date.isToday {
            return resGetString("Today")
        }
        
        if date.isYesterday {
            return resGetString("Yesterday")
        }
        
        return date.monthDayWeekdaySymbolString
    }
}

// MARK: - GoalRecordProcessorDelegate
extension GoalRecordListViewModel {
    
    func didChangeRemoteGoalRecord(with results: EntityChangeResults<GoalRecord>?) {
        DispatchQueue.main.async { [weak self] in
            self?.reload()
        }
    }
    
    func didCreateGoalRecord(_ record: GoalRecord, for task: GoalTask) {
        reloadIfNeeded(for: task)
    }
    
    func didUpdateGoalRecord(_ record: GoalRecord, for task: GoalTask, with change: GoalRecordChange) {
        reloadIfNeeded(for: task)
    }
    
    func didDeleteGoalRecords(for task: GoalTask?, in dateRange: DateRange?) {
        if let task = task, task.identifier != self.task.identifier {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.reload()
        }
    }
    
    /// 仅当变更属于当前任务时才刷新
    private func reloadIfNeeded(for task: GoalTask) {
        guard task.identifier == self.task.identifier else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.reload()
        }
    }
}
