//
//  CountdownMilestoneListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/21.
//

import Foundation
import UIKit

// MARK: - 已设置里程碑列表视图
/// 横向展示已设置的里程碑，支持长按删除
class CountdownMilestoneListView: TPCollectionWrapperView,
                                  TPCollectionSingleSectionListDataSource,
                                  TPCollectionViewAdapterDelegate,
                                  TPCollectionCellDelegate,
                                  TPMultipleItemSelectionUpdater {
    
    /// 单元格条目内间距
    let itemPadding = UIEdgeInsets(horizontal: 10.0)
    
    /// 单元格条目高度
    let itemHeight = 40.0
    
    /// 单元格最小宽度
    let minimumItemWidth = 66.0
    
    /// 点击里程碑回调
    var didClickMilestone: ((CountdownMilestone) -> Void)?
    
    /// 里程碑选择管理器
    var selection: TPMultipleItemSelection<CountdownMilestone>? {
        didSet {
            selection?.addUpdater(self)
        }
    }
    
    /// 是否可以编辑
    var editingEnabled: Bool = false
    
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.cornerRadius = 8.0
        style.backgroundColor = .tertiarySystemGroupedBackground
        return style
    }()
    
    var date: CountdownDate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hideScrollIndicator()
        scrollDirection = .horizontal
        adapter.cellClass = CountdownMilestoneCollectionCell.self
        adapter.sectionInset = UIEdgeInsets(horizontal: 8.0)
        adapter.interitemSpacing = 8.0
        adapter.lineSpacing = 8.0
        adapter.dataSource = self
        adapter.delegate = self
        
        let placeholderProvider = TPDefaultPlaceholderProvider()
        placeholderProvider.emptyTitle = resGetString("No Milestone")
        self.placeholderProvider = placeholderProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionListDataSource
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let selection = selection else {
            return nil
        }
        
        return selection.selectedItems.sorted().map {
            CountdownMilestoneItem($0, date: date)
        }
    }
    
    // MARK: - CollectionListDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleFont = CountdownMilestoneCollectionCell.titleFont
        let item = adapter.item(at: indexPath) as! CountdownMilestoneItem
        let titleWidth = item.milestone.title.width(with: titleFont)
        let width = titleWidth + itemPadding.horizontalLength
        return CGSize(width: max(width, minimumItemWidth), height: itemHeight)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        let cell = cell as! CountdownMilestoneCollectionCell
        cell.delegate = self
        cell.contentView.padding = itemPadding
        cell.cellStyle = cellStyle
        cell.milestoneItem = adapter.item(at: indexPath) as? CountdownMilestoneItem
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        TPImpactFeedback.impactWithSoftStyle()
        if editingEnabled {
            let cell = adapter.cellForItem(at: indexPath) as! CountdownMilestoneCollectionCell
            cell.showMenu(with: [.delete])
        }
        
        if let item = adapter.item(at: indexPath) as? CountdownMilestoneItem {
            didClickMilestone?(item.milestone)
        }
    }
    
    func collectionCell(_ cell: TPCollectionCell, perfomMenuAction type: TPCollectionCell.MenuActionType) {
        guard let indexPath = adapter.indexPath(for: cell),
              let item = adapter.item(at: indexPath) as? CountdownMilestoneItem else {
            return
        }
        
        if type == .delete {
            selection?.deselectItem(item.milestone)
        }
    }
    
    // MARK: - TPMultipleItemSelectionUpdater
    func multipleItemSelectionDidChange<T>(inserts: Set<T>?, deletes: Set<T>?) where T : Hashable {
        adapter.performUpdate()
        
        guard let selection = selection,
              let milestones = inserts as? Set<CountdownMilestone>,
              milestones.count == 1,
              let milestone = milestones.first,
              selection.isSelectedItem(milestone) else {
            return
        }
        
        scrollToAndCommitFocusAnimation(for: milestone)
    }
    
    public func scrollToAndCommitFocusAnimation(for milestone: CountdownMilestone) {
        if let item = milestoneItem(for: milestone) {
            adapter.scrollToItem(item,
                                 at: .centeredHorizontally,
                                 animated: true) { [weak self] _ in
                self?.adapter.commitFocusAnimation(for: item)
            }
        }
    }
    
    private func milestoneItem(for milestone: CountdownMilestone) -> CountdownMilestoneItem? {
        guard let items = adapter.visibleItems as? [CountdownMilestoneItem] else {
            return nil
        }
        
        let result = items.first { item in
            return item.milestone == milestone
        }
        
        return result
    }
}

// MARK: - 已设置里程碑单元格
/// 已设置里程碑单元格条目
class CountdownMilestoneListTableCellItem: TPBaseTableCellItem {
    
    /// 里程碑选择管理器
    var selection: TPMultipleItemSelection<CountdownMilestone>?
    
    /// 是否可编辑
    var editingEnabled: Bool = false
    
    /// 点击里程碑回调
    var didClickMilestone: ((CountdownMilestone) -> Void)?
    
    /// 单元格样式
    var cellStyle = TPCollectionCellStyle()
    
    override init() {
        super.init()
        selectionStyle = .none
        registerClass = CountdownMilestoneListTableViewCell.self
        cellStyle.cornerRadius = 8.0
        cellStyle.backgroundColor = .tertiarySystemGroupedBackground
    }
}

/// 已设置里程碑单元格
class CountdownMilestoneListTableViewCell: TPBaseTableCell {
    
    override var cellItem: TPBaseTableCellItem? {
        didSet {
            guard let cellItem = cellItem as? CountdownMilestoneListTableCellItem else {
                return
            }
            
            listView.selection = cellItem.selection
            listView.editingEnabled = cellItem.editingEnabled
            listView.didClickMilestone = cellItem.didClickMilestone
            listView.cellStyle = cellItem.cellStyle
            listView.reloadData()
        }
    }
    
    var listView: CountdownMilestoneListView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        listView = CountdownMilestoneListView(frame: bounds)
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
