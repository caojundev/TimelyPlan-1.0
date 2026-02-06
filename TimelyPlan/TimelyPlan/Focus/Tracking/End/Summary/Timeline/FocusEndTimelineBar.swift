//
//  FocusEndTimelineBar.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/15.
//

import Foundation
import UIKit

class FocusEndTimelineBar: UIView {
    
    /// 数据对象
    private(set) var dataItem: FocusEndDataItem?
    
    /// 会话图层内容视图
    private let contentView = UIView()
    
    /// 会话视图数组
    private var recordBars: [FocusRecordTimelineBar] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.addSubview(contentView)
        self.backgroundColor = Color(0x232323)
        self.setupRecordBars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    
        guard let dataItem = dataItem else {
            contentView.removeAllSubviews()
            recordBars.removeAll()
            return
        }
        
        let startDate = dataItem.startDate
        let totalInterval = dataItem.interval
        for recordBar in recordBars {
            let timeline = recordBar.timeline
            let barInterval = timeline.totalInterval
            if barInterval > 0, totalInterval > 0 {
                let offset = timeline.startDate.timeIntervalSince(startDate)
                let x = bounds.width * (offset / totalInterval)
                let w = bounds.width * (barInterval / totalInterval)
                recordBar.frame = CGRect(x: x, y: 0, width: w, height: bounds.height)
            } else {
                recordBar.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
            }
        }
    }
    
    private func setupRecordBars() {
        contentView.removeAllSubviews()
        recordBars.removeAll()        
        guard let dataItem = dataItem else {
            return
        }
        
        let records = dataItem.allRecords
        for record in records {
            let bar = FocusRecordTimelineBar(timeline: record.timeline)
            bar.backgroundColor = record.color ?? .primary
            recordBars.append(bar)
            contentView.addSubview(bar)
        }
        
        setNeedsLayout()
    }
    
    func reloadData(with dataItem: FocusEndDataItem?) {
        self.dataItem = dataItem
        setupRecordBars()
        setNeedsLayout()
    }
}
