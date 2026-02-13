//
//  FocusRecordListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/7.
//

import Foundation

class FocusRecordListViewController: StatsContentViewController,
                                     FocusSessionProcessorDelegate {
    
    /// 任务
    var task: TaskRepresentable?
    
    /// 计时器
    var timer: FocusTimer?
    
    /// 排序方式，默认为降序(最新的在前面)
    var sortOrder: FocusRecordSortOrder = .ascending
    
    override func viewDidLoad() {
        super.viewDidLoad()
        focus.addUpdaterDelegate(self)
    }
    
    override func placeholderView() -> UIView? {
        let view = TPDefaultPlaceholderView()
        view.image = resGetImage("focus_record_80")
        view.title = resGetString("No Focus Record")
        view.titleColor = .lightGray
        return view
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
                                                                         sessions: sortedSessions)
                sectionControllers.append(sectionController)
            }
        }

        return sectionControllers
    }
    
    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSession(_ session: FocusSession, with record: FocusRecord) {
        guard let date = session.startDate, self.dateRange.contains(date: date) else {
            return
        }
        
        self.reloadData {
            self.adapter.scrollToItem(session, at: .centeredVertically, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: session)
            }
        }
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.reloadData {
            self.adapter.scrollToItem(session, at: .centeredVertically, animated: true) { _ in
                self.adapter.commitFocusAnimation(for: session)
            }
        }
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        self.reloadData()
    }
    
}
