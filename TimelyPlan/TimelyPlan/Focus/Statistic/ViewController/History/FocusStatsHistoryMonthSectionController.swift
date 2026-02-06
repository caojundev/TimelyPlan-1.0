//
//  FocusStatsHistoryMonthSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/17.
//

import Foundation
import UIKit

class FocusStatsHistoryMonthSectionController: FocusStatsHistorySectionController {
 
    /// 统计数据条目
    var dataItem: FocusStatsDataItem?
    
    var date: Date
 
    /// 按月份的日信息数组字典
    var monthDayInfos: [Int: [FocusStatsDayInfo]]? {
        didSet {
            updateCellItems()
        }
    }
    
    init(date: Date, monthDayInfos: [Int: [FocusStatsDayInfo]]? = nil) {
        self.date = date
        self.monthDayInfos = monthDayInfos
        super.init()
        self.updateCellItems()
    }

    override func updateCellItems() {
        guard let monthDayInfos = monthDayInfos, monthDayInfos.count > 0 else {
            self.cellItems = [emptyCellItem]
            return
        }
        
        var cellItems = [FocusStatsHistoryMonthCellItem]()
        for month in stride(from: MONTHS_PER_YEAR, to: 0, by: -1) {
            guard let dayInfos = monthDayInfos[month], dayInfos.count > 0 else {
                continue
            }
            
            
            let monthDate = date.dateByReplacingMonthAndDay(month: month, day: 1)!
            let cellItem = FocusStatsHistoryMonthCellItem(date: monthDate,
                                                          days: dayInfos.count,
                                                          times: dayInfos.times,
                                                          duration: dayInfos.duration)
            cellItem.delegate = self /// 单元格
            cellItems.append(cellItem)
            
        }
        
        self.cellItems = cellItems
    }
    
    override func didSelectItem(at index: Int) {
        super.didSelectItem(at: index)
        guard let cellItem = item(at: index) as? FocusStatsHistoryMonthCellItem else {
            return
        }
        
        FocusPresenter.showRecords(forTask: dataItem?.task,
                                   timer: dataItem?.timer,
                                   type: .month,
                                   date: cellItem.date)
    }
}

class FocusStatsHistoryMonthCellItem: TPCollectionCellItem {
    
    /// 月份日期
    var date: Date
    
    /// 专注天数
    var days: Int
    
    /// 专注次数
    var times: Int
    
    /// 专注总时长
    var duration: Duration
    
    init(date: Date, days: Int, times: Int, duration: Duration) {
        self.date = date
        self.days = days
        self.times = times
        self.duration = duration
        super.init()
        self.registerClass = FocusStatsHistoryMonthCell.self
        self.size = CGSize(width: .greatestFiniteMagnitude, height: 130.0)
        self.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 10.0)
    }
}

class FocusStatsHistoryMonthCell: FocusStatsHistoryCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            guard let cellItem = cellItem as? FocusStatsHistoryMonthCellItem else {
                infoView.resetTitle()
                return
            }
            
            headerLabel.text = cellItem.date.yearMonthString
            infoView[0].title = cellItem.duration.attributedTitle()
            infoView[1].title = "\(cellItem.days)"
            infoView[2].title = "\(cellItem.times)"
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        infoView[0].subtitle = resGetString("Focus duration")
        infoView[1].subtitle = resGetString("Focus days")
        infoView[2].subtitle = resGetString("Focus times")
    }
}
