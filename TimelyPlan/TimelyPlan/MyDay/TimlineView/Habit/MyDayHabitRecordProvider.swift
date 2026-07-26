//
//  MyDayHabitRecordProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/25.
//

import Foundation

class MyDayHabitRecordProvider {
    
    // MARK: - Cache Storage
    // 第一层key: task.identifier, 第二层key: 日期整数(如20260725)
    private var recordCache: [String: [Int32: CacheEntry]] = [:]
    
    // MARK: - Pending Requests Management
    // 管理正在进行的请求，第一层key: task.identifier, 第二层key: 日期整数
    private var requestTokens: [String: [Int32: UUID]] = [:]
    
    private let updater = HabitRecordProcessorUpdater()
    
    // MARK: - Cache Entry
    private enum CacheEntry {
        case record(HabitRecord?)
        case notFound
    }
    
    init() {
        HabitRepository.addUpdater(self, for: [.record])
    }
    
    // MARK: - Public Methods
    
    func addUpdaterDelegate(_ delegate: HabitRecordProcessorDelegate) {
        updater.addDelegate(delegate)
    }
    
    func removeUpdaterDelegate(_ delegate: HabitRecordProcessorDelegate) {
        updater.removeDelegate(delegate)
    }
    
    func fetchRecord(for task: HabitTask,
                     on date: Date,
                     completion: @escaping (HabitRecord?) -> Void) {
        
        let dayKey = date.dayIntegerKey
        let taskId = task.identifier
        
        // 先从缓存中查找
        if let cachedResult = getCachedRecord(taskId: taskId, dayKey: dayKey) {
            completion(cachedResult)
            return
        }
        
        // 生成新的token
        let currentToken = generateNewToken(taskId: taskId, dayKey: dayKey)
        
        // 发起请求
        HabitRepository.fetchRecord(for: task, on: date) { [weak self] record in
            guard let self = self else { return }
            
            // 检查token是否仍然有效（没有更新的请求）
            if self.isTokenValid(currentToken, taskId: taskId, dayKey: dayKey) {
                // token有效，更新缓存
                self.updateCache(taskId: taskId, dayKey: dayKey, record: record)
            }
            
            // 无论token是否有效，都要通知外部
            completion(record)
        }
    }
    
    /// 保存任务在特定日期的记录（直接更新缓存）
    func saveRecord(_ record: HabitRecord?, for task: HabitTask, on date: Date) {
        let dayKey = date.dayIntegerKey
        let taskId = task.identifier
        
        // 生成新token，使正在进行的请求失效
        _ = generateNewToken(taskId: taskId, dayKey: dayKey)
        
        // 更新缓存
        updateCache(taskId: taskId, dayKey: dayKey, record: record)
    }
    
    /// 强制刷新缓存
    func refreshRecord(for task: HabitTask,
                      on date: Date,
                      completion: @escaping (HabitRecord?) -> Void) {
        
        let dayKey = date.dayIntegerKey
        let taskId = task.identifier
        
        // 清除缓存
        recordCache[taskId]?.removeValue(forKey: dayKey)
        
        // 生成新的token
        let currentToken = generateNewToken(taskId: taskId, dayKey: dayKey)
        
        // 发起请求
        HabitRepository.fetchRecord(for: task, on: date) { [weak self] record in
            guard let self = self else { return }
            
            // 检查token是否仍然有效
            if self.isTokenValid(currentToken, taskId: taskId, dayKey: dayKey) {
                // token有效，更新缓存
                self.updateCache(taskId: taskId, dayKey: dayKey, record: record)
            }
            
            // 通知外部
            completion(record)
        }
    }
    
    /// 批量获取记录
    func fetchRecords(for tasks: [HabitTask],
                     on date: Date,
                     completion: @escaping ([String: HabitRecord?]) -> Void) {
        
        let group = DispatchGroup()
        var results: [String: HabitRecord?] = [:]
        
        for task in tasks {
            group.enter()
            fetchRecord(for: task, on: date) { record in
                results[task.identifier] = record
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    /// 删除特定task在dateInterval之间的记录
    func deleteRecords(for task: HabitTask, in dateInterval: DateInterval) {
        let taskId = task.identifier
        
        // 计算起始和结束的Int32 key
        let startKey: Int32
        let endKey: Int32
        
        if dateInterval.start == Date.distantPast {
            startKey = 0
        } else {
            startKey = dateInterval.start.dayIntegerKey
        }
        
        if dateInterval.end == Date.distantFuture {
            endKey = Int32.max
        } else {
            endKey = dateInterval.end.dayIntegerKey
        }
        
        // 使所有相关请求token失效
        invalidateTokensForTask(taskId, startKey: startKey, endKey: endKey)
        
        // 删除缓存中在范围内的记录
        guard var taskCache = recordCache[taskId] else {
            return
        }
        
        taskCache = taskCache.filter { dayKey, _ in
            return dayKey < startKey || dayKey > endKey
        }
        
        if taskCache.isEmpty {
            recordCache.removeValue(forKey: taskId)
        } else {
            recordCache[taskId] = taskCache
        }
    }
    
    /// 获取特定任务在某个日期区间的所有记录（从缓存中）
    func getCachedRecords(for task: HabitTask, in dateInterval: DateInterval) -> [Int32: HabitRecord?] {
        let taskId = task.identifier
        
        guard let taskCache = recordCache[taskId] else {
            return [:]
        }
        
        // 计算起始和结束的Int32 key
        let startKey: Int32
        let endKey: Int32
        
        if dateInterval.start == Date.distantPast {
            startKey = 0
        } else {
            startKey = dateInterval.start.dayIntegerKey
        }
        
        if dateInterval.end == Date.distantFuture {
            endKey = Int32.max
        } else {
            endKey = dateInterval.end.dayIntegerKey
        }
        
        // 筛选范围内的记录
        let filteredCache = taskCache.filter { dayKey, _ in
            return dayKey >= startKey && dayKey <= endKey
        }
        
        var result: [Int32: HabitRecord?] = [:]
        
        for (dayKey, cachedEntry) in filteredCache {
            switch cachedEntry {
            case .record(let record):
                result[dayKey] = record
            case .notFound:
                result[dayKey] = nil
            }
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    /// 生成新的token并返回
    private func generateNewToken(taskId: String, dayKey: Int32) -> UUID {
        let newToken = UUID()
        
        if requestTokens[taskId] == nil {
            requestTokens[taskId] = [:]
        }
        requestTokens[taskId]?[dayKey] = newToken
        
        return newToken
    }
    
    /// 检查token是否有效
    private func isTokenValid(_ token: UUID, taskId: String, dayKey: Int32) -> Bool {
        return requestTokens[taskId]?[dayKey] == token
    }
    
    /// 使指定任务在日期范围内的所有token失效
    private func invalidateTokensForTask(_ taskId: String, startKey: Int32, endKey: Int32) {
        guard var taskTokens = requestTokens[taskId] else {
            return
        }
        
        taskTokens = taskTokens.filter { dayKey, _ in
            return dayKey < startKey || dayKey > endKey
        }
        
        if taskTokens.isEmpty {
            requestTokens.removeValue(forKey: taskId)
        } else {
            requestTokens[taskId] = taskTokens
        }
    }
    
    /// 从缓存中获取记录
    private func getCachedRecord(taskId: String, dayKey: Int32) -> HabitRecord?? {
        guard let taskCache = recordCache[taskId],
              let cachedEntry = taskCache[dayKey] else {
            return nil
        }
        
        switch cachedEntry {
        case .record(let record):
            return record
        case .notFound:
            return .some(nil)
        }
    }
    
    /// 更新缓存
    private func updateCache(taskId: String, dayKey: Int32, record: HabitRecord?) {
        if recordCache[taskId] == nil {
            recordCache[taskId] = [:]
        }
        
        if let record = record {
            recordCache[taskId]?[dayKey] = .record(record)
        } else {
            recordCache[taskId]?[dayKey] = .notFound
        }
    }
    
    // MARK: - Cache Management
    
    /// 清除所有缓存和token
    func clearAllCache() {
        recordCache.removeAll()
        requestTokens.removeAll()
    }
    
    /// 清除特定任务的所有缓存和token
    func clearCache(for task: HabitTask) {
        let taskId = task.identifier
        
        recordCache.removeValue(forKey: taskId)
        requestTokens.removeValue(forKey: taskId)
    }
    
    /// 清除特定任务在特定日期的缓存
    func clearCache(for task: HabitTask, on date: Date) {
        let dayKey = date.dayIntegerKey
        let taskId = task.identifier
        
        if var taskCache = recordCache[taskId] {
            taskCache.removeValue(forKey: dayKey)
            
            if taskCache.isEmpty {
                recordCache.removeValue(forKey: taskId)
            } else {
                recordCache[taskId] = taskCache
            }
        }
        
        if var taskTokens = requestTokens[taskId] {
            taskTokens.removeValue(forKey: dayKey)
            
            if taskTokens.isEmpty {
                requestTokens.removeValue(forKey: taskId)
            } else {
                requestTokens[taskId] = taskTokens
            }
        }
    }
    
    /// 清除缓存和token
    /// - Parameters:
    ///   - task: 特定任务，为nil时清除所有任务
    ///   - range: 日期区间
    func clearCache(for task: HabitTask?, in range: DateInterval) {
        // 计算起始和结束的Int32 key
        let startKey: Int32
        let endKey: Int32
        
        if range.start == Date.distantPast {
            startKey = 0
        } else {
            startKey = range.start.dayIntegerKey
        }
        
        if range.end == Date.distantFuture {
            endKey = Int32.max
        } else {
            endKey = range.end.dayIntegerKey
        }
        
        // 确定要处理的任务ID列表
        let taskIds: [String]
        if let task = task {
            taskIds = [task.identifier]
        } else {
            taskIds = Array(recordCache.keys)
        }
        
        // 清除缓存
        for taskId in taskIds {
            if var taskCache = recordCache[taskId] {
                taskCache = taskCache.filter { dayKey, _ in
                    return dayKey < startKey || dayKey > endKey
                }
                
                if taskCache.isEmpty {
                    recordCache.removeValue(forKey: taskId)
                } else {
                    recordCache[taskId] = taskCache
                }
            }
            
            // 清除token
            if var taskTokens = requestTokens[taskId] {
                taskTokens = taskTokens.filter { dayKey, _ in
                    return dayKey < startKey || dayKey > endKey
                }
                
                if taskTokens.isEmpty {
                    requestTokens.removeValue(forKey: taskId)
                } else {
                    requestTokens[taskId] = taskTokens
                }
            }
        }
    }
    
    /// 检查是否有正在进行的请求
    func hasPendingRequest(for task: HabitTask, on date: Date) -> Bool {
        let dayKey = date.dayIntegerKey
        let taskId = task.identifier
        
        return requestTokens[taskId]?[dayKey] != nil
    }
}

extension MyDayHabitRecordProvider: HabitRecordProcessorDelegate {
    
    /// 远程习惯记录改变
    func didChangeRemoteHabitRecord(with results: EntityChangeResults<HabitRecord>?) {
        clearAllCache()
        updater.didChangeRemoteHabitRecord(with: results)
    }
    
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        clearCache(for: task, on: date)
        updater.didUpdateHabitRecord(record, for: task, on: date, with: change)
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        clearCache(for: task, in: dateRange.interval)
        updater.didDeleteHabitRecords(for: task, in: dateRange)
    }

}
