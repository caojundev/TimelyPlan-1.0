//
//  AlarmPresetListTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/9.
//

import Foundation
import UIKit

class AlarmPresetListTableCellItem: TPBaseTableCellItem {
    
    /// 当前日期
    var eventDate: Date?
    
    /// 列表提醒数组
    var alarms: [TaskAlarm] = []
    
    /// 提醒选择管理器
    var selection: TPMultipleItemSelection<TaskAlarm>?
    
    /// 每行条目数
    var itemsCountPerRow = 3
    
    /// 条目高度
    var itemHeight = 60.0
    
    override var height: CGFloat {
        get {
            let rowsCount = AlarmPresetListView.rowsCount(totalItemsCount: alarms.count,
                                                          itemsCountPerRow: itemsCountPerRow)
            return CGFloat(rowsCount) * itemHeight
        }
        
        set { }
    }
    
    override init() {
        super.init()
        registerClass = AlarmPresetListTableCell.self
        selectionStyle = .none
    }
}

class AlarmPresetListTableCell: TPBaseTableCell {
    
    var alrams: [TaskAlarm] = []
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? AlarmPresetListTableCellItem else {
                return
            }
            
            listView.eventDate = cellItem.eventDate
            listView.alarms = cellItem.alarms
            listView.selection = cellItem.selection
            listView.reloadData()
            setNeedsLayout()
        }
    }
    
    var listView: AlarmPresetListView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        listView = AlarmPresetListView(frame: bounds)
        contentView.addSubview(listView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        listView.frame = bounds
    }
    
}
