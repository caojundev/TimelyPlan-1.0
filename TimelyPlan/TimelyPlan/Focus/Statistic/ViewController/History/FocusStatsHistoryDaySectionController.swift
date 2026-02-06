//
//  FocusStatsHistoryDaySectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/15.
//

import Foundation

class FocusStatsHistoryDaySectionController: FocusStatsHistorySectionController {
    
    /// 统计数据条目
    var dataItem: FocusStatsDataItem?
    
    var dayInfos: [FocusStatsDayInfo]? {
        didSet {
            self.updateCellItems()
        }
    }
    
    init(dayInfos: [FocusStatsDayInfo]? = nil) {
        self.dayInfos = dayInfos
        super.init()
        self.updateCellItems()
    }

    override func updateCellItems() {
        guard let dayInfos = dayInfos, dayInfos.count > 0 else {
            self.cellItems = [emptyCellItem]
            return
        }
        
        var cellItems = [FocusStatsHistoryDayCellItem]()
        for dayInfo in dayInfos {
            let cellItem = FocusStatsHistoryDayCellItem(dayInfo: dayInfo)
            cellItem.delegate = self /// 单元格
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)  
        guard let cellItem = item(at: index) as? FocusStatsHistoryDayCellItem else {
            return
        }
        
        FocusPresenter.showRecords(forTask: dataItem?.task,
                                   timer: dataItem?.timer,
                                   type: .day,
                                   date: cellItem.dayInfo.date)
    }
}

class FocusStatsHistoryDayCellItem: TPCollectionCellItem {
    
    var dayInfo: FocusStatsDayInfo
    
    init(dayInfo: FocusStatsDayInfo) {
        self.dayInfo = dayInfo
        super.init()
        self.registerClass = FocusStatsHistoryDayCell.self
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 100.0)
        self.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
    }
}

class FocusStatsHistoryDayCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? FocusStatsHistoryDayCellItem else {
                return
            }
            
            self.dayInfo = cellItem.dayInfo
        }
    }
    
    /// 日专注统计信息
    var dayInfo: FocusStatsDayInfo? {
        didSet {
            updateContent()
        }
    }
    
    /// 日期标签
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = resGetColor(.title)
        return label
    }()
    
    /// 时长标签
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 26.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = resGetColor(.title)
        return label
    }()
    
    /// 活动视图
    private var activityView = FocusHourlyActivityView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(dateLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(activityView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = contentView.layoutFrame()
        activityView.padding = UIEdgeInsets(value: 5.0)
        activityView.sizeToFit()
        activityView.right = layoutFrame.maxX
        activityView.centerY = layoutFrame.midY
        
        
        let labelWidth = activityView.left - layoutFrame.minX
        dateLabel.width = labelWidth
        dateLabel.height = layoutFrame.height * 0.4
        dateLabel.origin = layoutFrame.origin
        
        durationLabel.width = labelWidth
        durationLabel.height = layoutFrame.height * 0.6
        durationLabel.left = layoutFrame.minX
        durationLabel.top = dateLabel.bottom
    }
    
    func updateContent() {
        dateLabel.text = dayInfo?.date.yearMonthDayWeekdaySymbolString(style: .short, omitYear: true)
        durationLabel.attributed.text = dayInfo?.duration.attributedTitle()
        activityView.hourlyActivity = dayInfo?.hourlyActivity
    }
}
