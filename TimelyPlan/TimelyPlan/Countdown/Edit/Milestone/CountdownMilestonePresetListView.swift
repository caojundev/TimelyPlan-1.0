//
//  CountdownMilestonePresetListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/21.
//

import Foundation
import UIKit

// MARK: - 预设里程碑列表视图
/// 网格展示预设里程碑，点击选中 / 反选
class CountdownMilestonePresetListView: TPCollectionWrapperView,
                                        TPCollectionSingleSectionListDataSource,
                                        TPCollectionViewAdapterDelegate,
                                        TPMultipleItemSelectionUpdater {
    
    /// 预设里程碑条目
    var items: [CountdownMilestoneItem] = []
    
    /// 里程碑选择管理器
    var selection: TPMultipleItemSelection<CountdownMilestone>? {
        didSet {
            selection?.addUpdater(self)
        }
    }
    
    /// 每行显示里程碑数目
    var milestonesCountPerRow: Int = 3
    
    /// 条目高度
    var itemHeight: CGFloat = 60.0
    
    /// 单元格内间距
    private var itemPadding = UIEdgeInsets(horizontal: 4.0)
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = 0.0
        style.backgroundColor = .secondarySystemGroupedBackground
        style.selectedBackgroundColor = .primary
        return style
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = TPGridsCollectionViewFlowLayout()
        setCollectionViewLayout(layout)
        
        hideScrollIndicator()
        adapter.cellClass = CountdownMilestoneCollectionCell.self
        adapter.interitemSpacing = 0.0
        adapter.lineSpacing = 0.0
        adapter.sectionInset = .zero
        adapter.dataSource = self
        adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = collectionViewLayout as! TPGridsCollectionViewFlowLayout
        layout.layoutStyle.columsCount = milestonesCountPerRow
        layout.layoutStyle.toColum = milestonesCountPerRow - 1
        let rowsCount = CountdownMilestonePresetListView.rowsCount(totalItemsCount: items.count,
                                                                   itemsCountPerRow: milestonesCountPerRow)
        layout.layoutStyle.rowsCount = rowsCount
        layout.layoutStyle.fromRow = 0
        layout.invalidateLayout()
    }
    
    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        return items
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionSize = adapter.collectionViewSize()
        let width = collectionSize.width / CGFloat(milestonesCountPerRow)
        return CGSize(width: width, height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! CountdownMilestoneCollectionCell
        cell.contentView.padding = itemPadding
        cell.cellStyle = cellStyle
        guard let item = adapter.item(at: indexPath) as? CountdownMilestoneItem else {
            return
        }
        
        cell.milestoneItem = item
        cell.isDisabled = !isMilestoneEnabled(item.milestone)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        guard let selection = selection,
              let item = adapter.item(at: indexPath) as? CountdownMilestoneItem else {
            return false
        }
        
        return selection.isSelectedItem(item.milestone)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = adapter.item(at: indexPath) as? CountdownMilestoneItem else {
            return false
        }
        
        return isMilestoneEnabled(item.milestone)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        guard let selection = selection,
              let item = adapter.item(at: indexPath) as? CountdownMilestoneItem else {
            return
        }
        
        selection.selectItem(item.milestone)
    }
    
    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        adapter.updateCheckmarks()
        
        if let cells = adapter.visibleCells as? [CountdownMilestoneCollectionCell] {
            for cell in cells {
                guard let milestoneItem = cell.milestoneItem else {
                    continue
                }
                
                cell.isDisabled = !isMilestoneEnabled(milestoneItem.milestone)
            }
        }
    }
    
    /// 里程碑是否可选中
    private func isMilestoneEnabled(_ milestone: CountdownMilestone) -> Bool {
        guard let selection = selection else {
            return true
        }
        
        if selection.isSelectedItem(milestone) {
            return true
        }
        
        return selection.canSelectItem(milestone)
    }
    
    // MARK: - Helper Methods
    static func rowsCount(totalItemsCount: Int,
                          itemsCountPerRow: Int) -> Int {
        var rowsCount = totalItemsCount / itemsCountPerRow
        if totalItemsCount % itemsCountPerRow != 0 {
            rowsCount += 1
        }
        
        return rowsCount
    }
}

// MARK: - 预设里程碑单元格
/// 预设里程碑单元格条目
class CountdownMilestonePresetListTableCellItem: TPBaseTableCellItem {

    /// 预设里程碑
    var milestones: [CountdownMilestone] = [] {
        didSet {
            items = milestones.map { CountdownMilestoneItem($0, date: date) }
        }
    }
    
    /// 集合条目
    private(set) var items: [CountdownMilestoneItem] = []
    
    /// 里程碑选择管理器
    var selection: TPMultipleItemSelection<CountdownMilestone>?
    
    /// 每行条目数
    var itemsCountPerRow = 3
    
    /// 条目高度
    var itemHeight = 60.0
    
    override var height: CGFloat {
        get {
            let rowsCount = CountdownMilestonePresetListView.rowsCount(totalItemsCount: milestones.count,
                                                                       itemsCountPerRow: itemsCountPerRow)
            return CGFloat(rowsCount) * itemHeight
        }
        
        set { }
    }
    
    let date: CountdownDate
    
    init(date: CountdownDate) {
        self.date = date
        super.init()
        registerClass = CountdownMilestonePresetListTableViewCell.self
        selectionStyle = .none
    }
}

/// 预设里程碑单元格
class CountdownMilestonePresetListTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? CountdownMilestonePresetListTableCellItem else {
                return
            }
            
            listView.items = cellItem.items
            listView.selection = cellItem.selection
            listView.reloadData()
            setNeedsLayout()
        }
    }
    
    var listView: CountdownMilestonePresetListView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        listView = CountdownMilestonePresetListView()
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

