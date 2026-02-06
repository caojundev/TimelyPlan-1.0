//
//  RepeatSpecificDateTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/20.
//

import Foundation

class RepeatSpecificDateTableCellItem: TPBaseTableCellItem {
    
    /// 日期选择管理器
    var selection: TPCalendarMultipleDateSelection = TPCalendarMultipleDateSelection()
    
    /// 点击日期回调
    var didClickDate: ((DateComponents) -> Void)?
    
    override init() {
        super.init()
        self.registerClass = RepeatSpecificDateTableCell.self
        self.selectionStyle = .none
        self.height = 70.0
    }
}

class RepeatSpecificDateTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? RepeatSpecificDateTableCellItem else {
                return
            }
      
            listView.selection = cellItem.selection
            listView.didClickDate = cellItem.didClickDate
            listView.reloadData()
        }
    }
    
    lazy var listView: RepeatSpecificDateListView = {
        let view = RepeatSpecificDateListView(frame: .zero)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(listView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.padding = UIEdgeInsets(value: 5.0)
        listView.frame = contentView.layoutFrame()
    }
}
