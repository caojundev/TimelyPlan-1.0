//
//  FocusRecordListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/7.
//

import Foundation
import UIKit

class FocusRecordListViewController: StatsContentViewController,
                                     FocusSessionProcessorDelegate,
                                     SettingAgentObserver {
    
    /// 任务
    var task: TaskRepresentable?
    
    /// 计时器
    var timer: FocusTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placeholderProvider.emptyImage = resGetImage("placeholder_record_80")
        self.placeholderProvider.emptyTitle = resGetString("No Focus Record")
        FocusState.shared.addObserver(self, forKeys: [.recordListOrder, .recordListMode])
        focus.addUpdater(self, for: [.session])
    }
    
    func settingAgentDidChangeValue(for keyName: String) {
        if keyName == FocusState.SettingKey.recordListMode.name {
            listModeChanged()
        } else {
            performUpdate()
        }
    }
    
    private func listModeChanged() {
        guard let sectionControllers = self.sectionControllers as? [FocusRecordListSectionController] else {
            return
        }
        
        let mode = FocusState.shared.recordListMode
        sectionControllers.forEach {
            $0.mode = mode
        }
        
        adapter.reloadData()
    }

    override func fetchSectionControllers(completion: @escaping ([TPCollectionBaseSectionController]) -> Void) {
        focus.fetchSessionsGroupedByDay(forTask: task, timer: timer, within: dateRange) { results in
            let sectionControllers: [FocusRecordListSectionController]
            if let results = results {
                sectionControllers = self.sectionControllers(with: results)
            } else {
                sectionControllers = []
            }
            
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(with daySessions: [Int32: [FocusSession]]) -> [FocusRecordListSectionController] {
        let mode = FocusState.shared.recordListMode
        let sortOrder = FocusState.shared.recordListOrder
        
        var sectionControllers = [FocusRecordListSectionController]()
        // 根据排序方式对数据进行排序
        let sortedDaySessions: [(key: Int32, value: [FocusSession])]
        switch sortOrder {
        case .ascending:
            sortedDaySessions = daySessions.sorted(by: { $0.key < $1.key })
        case .descending:
            sortedDaySessions = daySessions.sorted(by: { $0.key > $1.key })
        }
        
        sortedDaySessions.forEach { key, value in
            if let date = Date.dateFromDayIntegerKey(key) {
                // 根据排序方式对每日的专注会话进行排序
                let sortedSessions: [FocusSession]
                switch sortOrder {
                case .ascending:
                    sortedSessions = value.orderedSessions(ascending: true)
                case .descending:
                    sortedSessions = value.orderedSessions(ascending: false)
                }
                
                let sectionController = FocusRecordListSectionController(date: date,
                                                                         sessions: sortedSessions,
                                                                         mode: mode)
                sectionControllers.append(sectionController)
            }
        }

        return sectionControllers
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        guard sessions.count == 1, let session = sessions.first else { return }
        guard let date = session.startDate, self.dateRange.contains(date: date) else {
            return
        }
        
        self.performUpdate()
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.performUpdate()
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        self.performUpdate()
    }
    
}
