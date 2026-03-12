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
    
    var titleConfig = TPLabelConfig.titleConfig
    
    var subtitleConfig = TPLabelConfig.subtitleConfig

    /// 点击提醒回调
    var didClickAlarm: ((TaskAlarm) -> Void)?
    
    var cellStyle = TPCollectionCellStyle()

    override init() {
        super.init()
        selectionStyle = .none
        registerClass = AlarmListTableViewCell.self
        titleConfig.textAlignment = .center
        titleConfig.font = .boldSystemFont(ofSize: 14.0)
        titleConfig.textColor = Color(0xFFFFFF, 0.8)
        subtitleConfig.textAlignment = .center
        cellStyle.cornerRadius = 8.0
        cellStyle.backgroundColor = .tertiarySystemGroupedBackground
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
            listView.titleConfig = cellItem.titleConfig
            listView.subtitleConfig = cellItem.subtitleConfig
            listView.cellStyle = cellItem.cellStyle
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
