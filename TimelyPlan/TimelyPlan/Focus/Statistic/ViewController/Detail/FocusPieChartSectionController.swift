//
//  FocusPieChartSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/3.
//

import Foundation
import UIKit

class FocusPieChartSectionController: TPCollectionItemSectionController {
    
    /// 统计数据条目
    let dataItem: FocusStatsDataItem
    
    /// 分组类型
    var groupType: FocusStatsDetailGroupType {
        didSet {
            guard groupType != oldValue else {
                return
            }

            cellItem.groupType = groupType
            updateVisual() /// 更新饼状图显示信息
        }
    }
    
    /// 选中分组类型回调
    var didSelectGroupType: ((FocusStatsDetailGroupType) -> Void)?
    
    /// 是否显示分组类型
    var canSelectGroupType: Bool = false {
        didSet {
            cellItem.canSelectGroupType = canSelectGroupType
        }
    }
    
    var cellItem = FocusPieChartCellItem()
    
    init(dataItem: FocusStatsDataItem, groupType: FocusStatsDetailGroupType) {
        self.dataItem = dataItem
        self.groupType = groupType
        super.init()
        self.layout.edgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        self.cellItem.headerTitle = resGetString("Focus Detail")
        let innerTitle: String
        if let duration = dataItem.duration, duration > 0 {
            innerTitle = duration.localizedTitle
        } else {
            innerTitle = resGetString("No Data")
        }

        self.cellItem.innerTitle = innerTitle
        self.cellItem.groupType = groupType
        self.cellItem.didSelectGroupType = {[weak self] groupType in
            self?.selectGroupType(groupType)
        }
        
        self.cellItem.canSelectGroupType = canSelectGroupType
        self.updateVisual()
        self.cellItems = [cellItem]
    }
    
    func updateVisual() {
        cellItem.visual = dataItem.detailPieVisual(groupType: groupType)
    }
    
    func selectGroupType(_ type: FocusStatsDetailGroupType) {
        guard self.groupType != type else {
            return
        }
        
        self.groupType = type
        self.didSelectGroupType?(type)
        self.adapter?.reloadCell(forItem: cellItem) /// 重新加载饼状图单元格
    }
}

class FocusPieChartCellItem: PieChartCellItem {
    
    /// 选中分组类型回调
    var didSelectGroupType: ((FocusStatsDetailGroupType) -> Void)?
    
    /// 分组类型
    var groupType: FocusStatsDetailGroupType = .task
    
    /// 是否可以选择分组类型
    var canSelectGroupType: Bool = false

    override init() {
        super.init()
        self.registerClass = FocusPieChartCell.self
    }
}

class FocusPieChartCell: PieChartCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            let cellItem = cellItem as! FocusPieChartCellItem
            self.didSelectGroupType = cellItem.didSelectGroupType
            self.groupType = cellItem.groupType
            self.canSelectGroupType = cellItem.canSelectGroupType
            setNeedsLayout()
        }
    }
    
    /// 选中分组类型回调
    var didSelectGroupType: ((FocusStatsDetailGroupType) -> Void)?
    
    /// 分组类型
    var groupType: FocusStatsDetailGroupType = .task {
        didSet {
            if groupType != oldValue {
                self.updateGroupButton()
            }
        }
    }

    /// 是否显示分组类型按钮
    var canSelectGroupType: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }

    private lazy var groupButton: TPMenuListButton = {
        let color = resGetColor(.title)
        let button = TPMenuListButton()
        button.titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        button.titleConfig.textColor = color
        button.imagePosition = .right
        button.imageConfig.margins = UIEdgeInsets(horizontal: 4.0)
        button.imageConfig.color = color
        button.image = resGetImage("chevron_upDown_16")
        button.didSelectMenuAction = {[weak self] action in
            let groupType: FocusStatsDetailGroupType? = action.actionType()
            if let groupType = groupType {
                self?.selectGroupType(groupType)
            }
        }
        
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        let layoutFrame = contentView.layoutFrame()
        self.groupButton.isHidden = !canSelectGroupType
        if canSelectGroupType {
            self.groupButton.sizeToFit()
            self.groupButton.right = layoutFrame.maxX
            self.groupButton.centerY = layoutFrame.minY + self.headerView.layoutFrame().midY
            self.headerView.width = self.headerView.width - self.groupButton.width
        } else {
            self.headerView.width = layoutFrame.width
        }
    }
    
    func updateGroupButton() {
        self.groupButton.title = groupType.title
        let lists = [FocusStatsDetailGroupType.allCases]
        self.groupButton.menuItems = TPMenuItem.items(with: lists, updater: { type, action in
            action.handleBeforeDismiss = true
            action.isChecked = type == self.groupType
        })
        
        self.setNeedsLayout()
    }
    
    func selectGroupType(_ type: FocusStatsDetailGroupType) {
        self.groupType = type
        self.updateGroupButton()
        self.didSelectGroupType?(type)
    }
       
}
