//
//  FocusRecordEditTimelineSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/9.
//

import Foundation

class FocusRecordEditTimelineSectionController: TPTableItemSectionController {

    /// 时间线对象
    var timeline: FocusRecordTimeline {
        return FocusRecordTimeline(startDate: startDate, recordDurations: recordDurations)
    }

    /// 改变时间线回调
    var didChangeTimeline: ((FocusRecordTimeline) -> Void)?
    
    /// 开始日期
    var startDate: Date
    
    /// 时间线会话数组
    var recordDurations: [FocusRecordDuration] {
        var recordDurations = [FocusRecordDuration]()
        for durationCellItem in durationCellItems {
            recordDurations.append(durationCellItem.recordDuration)
        }
        
        return recordDurations
    }
    
    /// 开始日期
    lazy var startDateCellItem: FocusRecordTimelineCellItem = { [weak self] in
        let cellItem = FocusRecordTimelineCellItem()
        cellItem.imageName = "focus_record_timeline_start_24"
        cellItem.title = resGetString("Start From")
        cellItem.timelineStyle = .bottom
        cellItem.accessoryType = .disclosureIndicator
        cellItem.updater = {
            self?.startDateCellItem.subtitle = self?.startDate.monthDayTimeString
        }
    
        return cellItem
    }()
    
    /// 结束日期
    lazy var endDateCellItem: FocusRecordTimelineCellItem = { [weak self] in
        let cellItem = FocusRecordTimelineCellItem()
        cellItem.imageName = "focus_record_timeline_ended_24"
        cellItem.title = resGetString("Ended At")
        cellItem.timelineStyle = .top
        cellItem.selectionStyle = .none
        cellItem.updater = {
            self?.endDateCellItem.subtitle = self?.timeline.endDate.monthDayTimeString
        }
        
        return cellItem
    }()

    /// 持续时间
    var durationCellItems: [FocusRecordDurationCellItem] = []

    init(timeline: FocusRecordTimeline) {
        self.startDate = timeline.startDate
        super.init()
        self.headerItem.height = 20.0
        
        self.durationCellItems = cellItems(for: timeline.recordDurations)
        var cellItems = [TPBaseTableCellItem]()
        cellItems.append(startDateCellItem)
        cellItems.append(contentsOf: self.durationCellItems)
        cellItems.append(endDateCellItem)
        self.cellItems = cellItems
    }
    
    func cellItems(for recordDurations: [FocusRecordDuration]) -> [FocusRecordDurationCellItem] {
        var cellItems = [FocusRecordDurationCellItem]()
        for recordDuration in recordDurations {
            let cellItem = cellItem(for: recordDuration)
            cellItems.append(cellItem)
        }
        
        return cellItems
    }
    
    func cellItem(for recordDuration: FocusRecordDuration) -> FocusRecordDurationCellItem {
        return FocusRecordDurationCellItem(recordDuration: recordDuration)
    }
 
    override func didSelectRow(at index: Int) {
        guard let cellItem = item(at: index) as? FocusRecordTimelineCellItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        if cellItem === startDateCellItem {
            self.editStartDateAndTime()
        } else if let cellItem = cellItem as? FocusRecordDurationCellItem {
            self.editRecordDuration(for: cellItem)
        }
    }
    
    // MARK: - Event Response
    /// 编辑开始日期
    func editStartDateAndTime() {
        let vc = TPDatePickerViewController()
        vc.date = timeline.startDate
        vc.didPickDate = { date in
            guard self.startDate != date else {
                return
            }
            
            self.startDate = date
            self.adapter?.reloadCell(forItems: [self.startDateCellItem, self.endDateCellItem], with: .none)
            self.didChangeTimeline?(self.timeline)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.popoverShow()
    }

    /// 编辑持续时长
    func editRecordDuration(for cellItem: FocusRecordDurationCellItem) {
        var recordDuration = cellItem.recordDuration
        let vc = TPDurationPickerViewController()
        vc.duration = Duration(recordDuration.interval)
        if recordDuration.type == .focus {
            vc.presetMinutes = [10, 15, 25, 30, 45, 60, 90, 120, 240]
            vc.minimumDuration = 5 * SECONDS_PER_MINUTE
        } else {
            vc.presetMinutes = [1, 5, 10, 15, 25, 30, 45, 60, 90]
            vc.minimumDuration = SECONDS_PER_MINUTE
        }
        
        vc.didPickDuration = { duration in
            let interval = TimeInterval(duration)
            guard recordDuration.interval != interval else {
                return
            }
            
            recordDuration.interval = interval
            cellItem.recordDuration = recordDuration
            self.adapter?.reloadCell(forItems: [cellItem, self.endDateCellItem], with: .none)
            self.adapter?.commitFocusAnimation(for: cellItem)
            self.didChangeTimeline?(self.timeline)
        }
        
        vc.popoverShowAsNavigationRoot()
    }
    
}


