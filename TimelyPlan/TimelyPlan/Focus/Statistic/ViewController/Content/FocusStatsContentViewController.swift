//
//  FocusStatsContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/4.
//

import Foundation

class FocusStatsContentViewController: StatsContentViewController,
                                        FocusSessionProcessorDelegate {
    
    /// 任务
    var task: TaskRepresentable?
    
    /// 计时器
    var timer: FocusTimer?
    
    /// 分组类型
    var groupType: FocusStatsDetailGroupType = .task
    
    /// 是否可以选择分组类型
    var canSelectGroupType: Bool = true
    
    /// 选中分组类型回调
    var didSelectGroupType: ((FocusStatsDetailGroupType) -> Void)?
    
    /// 统计模式
    var mode: FocusStatsMode {
        if timer == nil && task == nil {
            return .overall
        } else if task == nil {
            return .specificTimer
        } else if timer == nil {
            return .specificTask
        } else {
            return .specificTimerAndTask
        }
    }
    
    /// 是否显示已归档计时器
    var showArchivedTimer: Bool {
        var result = true
        let mode = self.mode
        if mode == .overall {
            result = FocusSetting.shared.isOverallStatsShowArchived
        }

        return result
    }
    
    override init(type: StatsType, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: type, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.mode != .overall {
            self.backViewMargins = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 100.0, right: 16.0)
        }
        
        focus.addUpdater(self, for: [.session])
    }
    
    /// 详情统计
    func detailSectionController(with dataItem: FocusStatsDataItem) -> FocusPieChartSectionController {
        let detailSectionController = dataItem.detailSectionController(groupType: groupType)
        detailSectionController.canSelectGroupType = canSelectGroupType
        detailSectionController.didSelectGroupType = { [weak self] groupType in
            self?.groupType = groupType
            self?.didSelectGroupType?(groupType)
        }
        
        return detailSectionController
    }

    // MARK: - FocusSessionProcessorDelegate
    func didAddFocusSessions(_ sessions: [FocusSession]) {
        var shouldReload = false
        for session in sessions {
            if let date = session.startDate, dateRange.contains(date: date) {
                shouldReload = true
                break
            }
        }
        
        if shouldReload {
            self.reloadData()
        }
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.reloadData()
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        self.reloadData()
    }
    
}
