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
    
    override init(type: StatsType, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: type, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        focus.addUpdaterDelegate(self)
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
    func didAddFocusSession(_ session: FocusSession, with record: FocusRecord) {
        guard let date = session.startDate, self.dateRange.contains(date: date) else {
            return
        }
        
        self.reloadData()
    }
    
    func didUpdateFocusSession(_ session: FocusSession) {
        self.reloadData()
    }
    
    func didDeleteFocusSession(_ session: FocusSession) {
        self.reloadData()
    }
    
}
