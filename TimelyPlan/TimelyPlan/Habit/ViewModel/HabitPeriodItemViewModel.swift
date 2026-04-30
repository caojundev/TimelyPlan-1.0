//
//  HabitPeriodItemViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/30.
//

import Foundation

class HabitPeriodItemViewModel: SettingAgentObserver,
                                TPMidnightUpdatable,
                                HabitTaskProcessorDelegate {
    
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
            self.placeholderProvider.state = loadingState
        }
    }
    
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    init() {
        self.placeholderProvider.state = self.loadingState
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
}
