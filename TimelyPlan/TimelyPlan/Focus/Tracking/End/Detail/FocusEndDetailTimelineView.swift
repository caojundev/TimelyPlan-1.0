//
//  FocusEndDetailTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/16.
//

import Foundation

/// 默认时间线行高
let kDefaultTimelineRowHeight = 60.0

class FocusEndDetailTimelineView: TPTableWrapperView,
                                  TPTableSectionControllersList {
    
    var sectionControllers: [TPTableBaseSectionController]?
    
    
    /// 时间线行高
    var rowHeight: CGFloat = kDefaultTimelineRowHeight
    
    /// 时间线对象
    var timeline: FocusRecordTimeline?
    
    init() {
        super.init(frame: .zero, style: .grouped)
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.cellStyle.backgroundColor = .clear
        self.adapter.cellStyle.selectedBackgroundColor = .clear
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.isScrollEnabled = false
        self.tableView.isUserInteractionEnabled = false
        self.tableView.separatorStyle = .none
        self.tableView.separatorInset = .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        let sectionControllers: [FocusEndDetailTimelineSectionController]
        if let timeline = timeline {
            let sectionController = FocusEndDetailTimelineSectionController(timeline: timeline)
            sectionController.rowHeight = rowHeight
            sectionControllers = [sectionController]
        } else {
            sectionControllers = []
        }
        
        self.sectionControllers = sectionControllers
        self.adapter.reloadData()
    }
}

class FocusEndDetailTimelineSectionController: TPTableItemSectionController {

    
    let timeline: FocusRecordTimeline
    
    /// 时间线行高
    var rowHeight: CGFloat = kDefaultTimelineRowHeight {
        didSet {
            guard rowHeight != oldValue, let cellItems = self.cellItems else {
                return
            }
            
            for cellItem in cellItems {
                cellItem.height = rowHeight
            }
        }
    }
    
    /// 开始日期
    lazy var startDateCellItem: FocusRecordTimelineCellItem = { [weak self] in
        let cellItem = FocusRecordTimelineCellItem()
        cellItem.height = rowHeight
        cellItem.imageName = "focus_record_timeline_start_24"
        cellItem.title = resGetString("Start From")
        cellItem.timelineStyle = .bottom
        cellItem.selectionStyle = .none
        cellItem.updater = {
            self?.startDateCellItem.subtitle = self?.timeline.startDate.monthDayTimeString
        }
    
        return cellItem
    }()
    
    /// 结束日期
    lazy var endDateCellItem: FocusRecordTimelineCellItem = { [weak self] in
        let cellItem = FocusRecordTimelineCellItem()
        cellItem.height = rowHeight
        cellItem.imageName = "focus_record_timeline_ended_24"
        cellItem.title = resGetString("Ended At")
        cellItem.timelineStyle = .top
        cellItem.selectionStyle = .none
        cellItem.updater = {
            self?.endDateCellItem.subtitle = self?.timeline.endDate.monthDayTimeString
        }
        
        return cellItem
    }()

    init(timeline: FocusRecordTimeline) {
        self.timeline = timeline
        super.init()
        
        var cellItems = [TPBaseTableCellItem]()
        cellItems.append(self.startDateCellItem)
        
        var fragmentCellItems = [FocusEndDetailTimeFragmentCellItem]()
        let timeFragmentInfos = timeline.timeFragmentInfos ?? []
        for info in timeFragmentInfos {
            let cellItem = FocusEndDetailTimeFragmentCellItem(durationType: info.type,
                                                              timeFragment: info.timeFragment)
            cellItem.height = rowHeight
            fragmentCellItems.append(cellItem)
        }
        
        cellItems.append(contentsOf: fragmentCellItems)
        cellItems.append(self.endDateCellItem)
        self.cellItems = cellItems
        self.headerItem.height = 0.0
        self.footerItem.height = 0.0
    }
}

class FocusEndDetailTimeFragmentCellItem: FocusRecordTimelineCellItem {
    
    var durationType: FocusRecordDurationType
    
    var timeFragment: TimeFragment
    
    init(durationType: FocusRecordDurationType, timeFragment: TimeFragment) {
        self.durationType = durationType
        self.timeFragment = timeFragment
        super.init()
        self.accessoryType = .none
        self.selectionStyle = .none
        self.updateInfo()
    }
    
    func updateInfo() {
        var imageName: String
        var title: String
        if durationType == .pause {
            imageName = "focus_record_timeline_paused_24"
            title = resGetString("Pause")
        } else {
            imageName = "focus_record_timeline_focus_24"
            title = resGetString("Focus")
        }
    
        self.imageName = imageName
        self.title = title
        let dateRange = DateRange(startDate: self.timeFragment.startDate,
                                  endDate: self.timeFragment.endDate)
        self.subtitle = dateRange.simpleTimeRangeString()
        self.valueConfig = .valueText(Duration(timeFragment.interval).localizedTitle)
    }
}
