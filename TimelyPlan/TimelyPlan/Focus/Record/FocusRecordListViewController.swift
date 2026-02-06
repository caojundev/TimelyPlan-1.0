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

    override func viewDidLoad() {
        super.viewDidLoad()
        focus.addUpdaterDelegate(self)
    }
    
    override func placeholderView() -> UIView? {
        let view = TPDefaultPlaceholderView()
        view.image = resGetImage("focus_record_80")
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
        daySessions.sorted(by: {$0.key < $1.key}).forEach { key, value in
            if let date = Date.dateFromDayIntegerKey(key) {
                let sectionController = FocusRecordListSectionController(date: date, sessions: value)
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
