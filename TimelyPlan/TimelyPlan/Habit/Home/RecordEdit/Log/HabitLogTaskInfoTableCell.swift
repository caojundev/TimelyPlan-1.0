//
//  HabitLogTaskInfoTableCell.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

class HabitLogTaskInfoTableCellItem: TPBaseTableCellItem {
    
    var task: HabitTask?
    
    var status: HabitTaskStatus = .notStarted
    
    override init() {
        super.init()
        self.registerClass = HabitLogTaskInfoTableCell.self
        self.selectionStyle = .none
        self.contentPadding = UIEdgeInsets(left: 12.0, right: 16.0)
        self.height = 70.0
        self.rightViewSize = .size(6)
    }
}

class HabitLogTaskInfoTableCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            let cellItem = cellItem as! HabitLogTaskInfoTableCellItem
            self.task = cellItem.task
            self.status = cellItem.status
            reloadData()
        }
    }
    
    var task: HabitTask?
    
    var status: HabitTaskStatus = .notStarted
    
    private let infoView = HabitTaskDefaultInfoView()
    
    private let statusImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.infoView)
        self.rightView = statusImageView
        self.statusImageView.alpha = 0.8
        self.rightViewSize = .size(6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        infoView.frame = availableLayoutFrame()
    }

    func reloadData() {
        infoView.iconView.foreColor = Color(0xffffff, 0.8)
        infoView.iconView.backColor = Color(0xcccccc, 0.2)
        infoView.iconView.icon = task?.icon
        infoView.titleView.title = task?.name
        
        var subtitle: String?
        switch status {
        case .notStarted, .inProgress:
            subtitle = nil
        case .completed:
            subtitle = resGetString("Completed")
        case .skipped(_):
            subtitle = resGetString("Skipped")
        case .failed(_):
            subtitle = resGetString("Failed")
        }
        
        let imageName = status.iconName(with: 24)
        if let imageName = imageName {
            statusImageView.image = resGetImage(imageName)
        }
        
        infoView.titleView.subtitle = subtitle
    }
    
}
