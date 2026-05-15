//
//  HabitPeriodItemViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/30.
//

import Foundation

class HabitPeriodItemViewModel: SettingAgentObserver,
                                TPMidnightUpdatable,
                                HabitTaskProcessorDelegate,
                                HabitRecordProcessorDelegate {

    weak var delegate: HabitRecordProcessorDelegate?

    /// 分组改变回调
    var groupsDidChange: (() -> Void)?
    
    var midnightHandler: (() -> Void)?
    
    var firstWeekDidChange: (() -> Void)?
    
    /// 过滤类型
    var filterType: HabitTaskFilterType = .all

    /// 任务分组
    private(set) var groups: [HabitTaskGroup]?

    /// 日期
    private(set) var period: HabitDatePeriod?

    private var periodItems: [HabitPeriodItem] = []
    
    private let requestManager = TPRequestManager()
    
    private var needsRefresh = true

    /// 加载状态
    private var loadingState: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = loadingState
        }
    }
    
    private(set) var placeholderProvider = HabitListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = .initialLoading
        habit.addUpdater(self, for: .all)
        /// 添加至凌晨更新对象
        TPMidnightScheduler.shared.addUpdater(self)
        HabitSetting.shared.addObserver(self, forKey: .firstWeekday)
    }
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.needsRefresh = refresh
    }
    
    func loadGroups(forceRefresh: Bool = false) {
        if let period = period {
            loadGroups(in: period, forceRefresh: forceRefresh)
        }
    }
    
    func loadGroups(on date: Date, forceRefresh: Bool = false) {
        let period = HabitDatePeriod(date: date, mode: .day)
        loadGroups(in: period, forceRefresh: forceRefresh)
    }
    
    func loadGroups(in period: HabitDatePeriod, forceRefresh: Bool = false) {
        if forceRefresh {
            setNeedsRefresh()
        }
        
        if self.loadingState != .initialLoading {
            self.loadingState = .loading
        }
        
        let requestID = requestManager.executeRequest()
        let filterType = self.filterType
        loadPeriodItemsIfNeeded(in: period) { periodItems in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            let periodItems = periodItems ?? []
            DispatchQueue.global(qos: .userInitiated).async {
                let groups = HabitPeriodItemOrganizer.groupAll(from: periodItems, with: filterType)
                DispatchQueue.main.async {
                    guard self.requestManager.shouldProceed(with: requestID) else {
                        return
                    }
                    
                    self.periodItems = periodItems
                    self.period = period
                    self.groups = groups
                    self.setNeedsRefresh(false)
                    self.loadingState = .loaded
                    self.groupsDidChange?()
                }
            }
        }
    }
    
    private func loadPeriodItemsIfNeeded(in period: HabitDatePeriod,
                                         completion: @escaping ([HabitPeriodItem]?) -> Void) {
        var bRefresh = needsRefresh
        if !bRefresh {
            /// 当period 不同时会强制更新
            bRefresh = (period != self.period)
        }
        
        guard bRefresh else {
            completion(self.periodItems)
            return
        }

        fetchPeriodItems(in: period, completion: completion)
    }
    
    /// 获取任务方法
    func fetchPeriodItems(in period: HabitDatePeriod, completion: @escaping ([HabitPeriodItem]?) -> Void) {
        completion(nil)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        if keyName == HabitSetting.Key.firstWeekday.name {
            firstWeekDidChange?()
        }
    }

    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        midnightHandler?()
    }
    
    // MARK: - HabitTaskProcessorDelegate
    func didCreateHabitTask(_ task: HabitTask) {
        self.loadGroups(forceRefresh: true)
    }

    func didUpdateHabitTask(_ task: HabitTask) {
        self.loadGroups(forceRefresh: true)
    }
    
    func didDeleteHabitTask(_ task: HabitTask) {
        self.loadGroups(forceRefresh: true)
    }
    
    func didChangeArchivedState(for task: HabitTask) {
        self.loadGroups(forceRefresh: true)
    }
    
    func didReorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        self.loadGroups(forceRefresh: true)
    }
    
    
    // MARK: - HabitRecordProcessorDelegate
    
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        updateHabitRecord(record, for: task, on: date)
        guard let period = self.period, period.contains(date) else {
            return
        }
        
        delegate?.didUpdateHabitRecord(record, for: task, on: date, with: change)
        guard filterType != .all else {
            return
        }
        
        callback(after: 0.4) {
            self.loadGroups()
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        deleteHabitRecords(for: task, in: dateRange)
        guard let currentPeriod = self.period, currentPeriod.intersects(dateRange) else {
            return
        }
        
        delegate?.didDeleteHabitRecords(for: task, in: dateRange)
        guard filterType != .all else {
            return
        }
        
        callback(after: 0.4) {
            self.loadGroups()
        }
    }
    
    // MARK: - Helpers
    func updateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date) {
        let periodItem = periodItem(for: task)
        periodItem?.updateRecord(record, on: date)
    }
        
    func deleteHabitRecord(for task: HabitTask, on date: Date) {
        let periodItem = periodItem(for: task)
        periodItem?.updateRecord(nil, on: date)
    }

    func deleteHabitRecords(for task: HabitTask?, in dateRange: DateRange) {
        if let task = task {
            let periodItem = periodItem(for: task)
            periodItem?.deleteRecords(in: dateRange)
        } else {
            periodItems.forEach { periodItem in
                periodItem.deleteRecords(in: dateRange)
            }
        }
    }
    
    func periodItem(for habitTask: HabitTask) -> HabitPeriodItem? {
        for periodItem in periodItems {
            if periodItem.habitTask.identifier == habitTask.identifier {
                return periodItem
            }
        }
        
        return nil
    }
}
