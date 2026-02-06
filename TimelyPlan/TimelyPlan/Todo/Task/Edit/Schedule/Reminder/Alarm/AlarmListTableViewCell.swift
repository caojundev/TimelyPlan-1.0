//
//  AlarmScheduleListTableViewCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/10.
//

import Foundation

class AlarmListTableCellItem: TPBaseTableCellItem {
    
    var eventDate: Date?
    
    /// 提醒选择管理器
    var selection: TPMultipleItemSelection<TaskAlarm>?
    
    /// 是否可编辑
    var editingEnabled: Bool = false
    
    /// 副标题是否隐藏
    var isSubtitleHidden: Bool = false
    
    /// 点击提醒回调
    var didClickAlarm: ((TaskAlarm) -> Void)?
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = AlarmListTableViewCell.self
    }
}

class AlarmListTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? AlarmListTableCellItem else {
                return
            }
      
            listView.eventDate = cellItem.eventDate
            listView.isSubtitleHidden = cellItem.isSubtitleHidden
            listView.selection = cellItem.selection
            listView.editingEnabled = cellItem.editingEnabled
            listView.didClickAlarm = cellItem.didClickAlarm
            listView.reloadData()
        }
    }
    
    var listView: AlarmListView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        listView = AlarmListView(frame: bounds)
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
