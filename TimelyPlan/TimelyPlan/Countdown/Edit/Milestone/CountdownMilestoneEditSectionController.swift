//
//  CountdownMilestoneEditSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/20.
//

import Foundation
import UIKit

// MARK: - 里程碑编辑区块
/// 参考 `TaskReminderEditSectionController` 实现，用于编辑倒数日提醒的里程碑，
/// 依次展示「已设置的里程碑（按类型与间隔排序）」「预设里程碑」「自定义里程碑」
class CountdownMilestoneEditSectionController: TPTableItemSectionController,
                                               TPMultipleItemSelectionDelegate {
    
    /// 是否可以添加新里程碑
    var canAddMilestone: (() -> Bool)?
    
    /// 点击自定义
    var didClickCustom: (() -> Void)?
    
    /// 里程碑改变
    var milestonesDidChange: (([CountdownMilestone]) -> Void)?
    
    /// 已设置的里程碑数目
    var milestonesCount: Int {
        return selection.selectedCount
    }
    
    /// 已设置的里程碑（按类型与间隔排序）
    var milestones: [CountdownMilestone] {
        return selection.selectedItems.sorted()
    }
    
    /// 里程碑选择管理器
    private var selection: TPMultipleItemSelection<CountdownMilestone>
    
    /// 已设置的里程碑
    lazy var milestonesCellItem: CountdownMilestoneListTableCellItem = {
        let cellItem = CountdownMilestoneListTableCellItem()
        cellItem.height = 60.0
        cellItem.editingEnabled = true
        return cellItem
    }()
    
    /// 预设里程碑
    lazy var presetMilestonesCellItem: CountdownMilestonePresetListTableCellItem = {
        let cellItem = CountdownMilestonePresetListTableCellItem(date: date)
        cellItem.milestones = CountdownMilestone.presets
        return cellItem
    }()
    
    /// 自定义里程碑
    lazy var customCellItem: TPFullSizeButtonTableCellItem = { [weak self] in
        let cellItem = TPFullSizeButtonTableCellItem()
        cellItem.buttonNormalTitleColor = resGetColor(.title)
        cellItem.buttonTitle = resGetString("Custom")
        cellItem.buttonImageName = "plus_24"
        cellItem.buttonImageColor = resGetColor(.title)
        cellItem.updater = {
            let canAddMilestone = self?.canAddMilestone?() ?? false
            self?.customCellItem.isDisabled = !canAddMilestone
        }
        
        cellItem.didClickButton = { _ in
            self?.didClickCustom?()
        }
        
        return cellItem
    }()
    
    /// 头标题
    var headerTitle: String? {
        didSet {
            headerItem.title = headerTitle
        }
    }
    
    let date: CountdownDate
    
    init(milestones: [CountdownMilestone]?, date: CountdownDate) {
        self.selection = TPMultipleItemSelection(items: milestones ?? [])
        self.date = date
        super.init()
        let headerItem = TPDefaultInfoTableHeaderFooterItem()
        headerItem.height = 0.0
        self.headerItem = headerItem
        
        self.selection.delegate = self
        self.milestonesCellItem.selection = self.selection
        self.presetMilestonesCellItem.selection = self.selection
        self.cellItems = [self.milestonesCellItem,
                          self.presetMilestonesCellItem,
                          self.customCellItem]
    }
    
    /// 更新里程碑可选状态
    func updateEnabled() {
        adapter?.reloadCell(forItem: customCellItem, with: .none)
        selection.notifyUpdaters(inserts: nil, deletes: nil)
    }
    
    /// 创建自定义里程碑
    func didCreateMilestone(_ milestone: CountdownMilestone) {
        if !selection.isSelectedItem(milestone) {
            selection.selectItem(milestone)
        }
    }
    
    // MARK: - TPMultipleItemSelectionDelegate
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canSelectItem item: T) -> Bool where T : Hashable {
        return canAddMilestone?() ?? false
    }
    
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, canDeselectItem item: T) -> Bool where T : Hashable {
        return true
    }
    
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didSelectItem item: T) where T : Hashable {
        updateEnabled()
        milestonesDidChange?(milestones)
    }
    
    func multipleItemSelection<T>(_ selection: TPMultipleItemSelection<T>, didDeselectItem item: T) where T : Hashable {
        updateEnabled()
        milestonesDidChange?(milestones)
    }
}

// MARK: - 里程碑集合条目
/// 集合视图条目，`CountdownMilestone` 为值类型，此处包装为 `NSObject` 以适配 `ListDiffable`
class CountdownMilestoneItem: NSObject {
    
    /// 里程碑
    let milestone: CountdownMilestone
    
    var date: CountdownDate?
    
    init(_ milestone: CountdownMilestone, date: CountdownDate?) {
        self.milestone = milestone
        self.date = date
        super.init()
    }
    
    /// 唯一标识（单位 + 间隔）
    var identifier: String {
        return "\(milestone.unit?.rawValue ?? -1)-\(milestone.interval ?? 0)"
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(milestone)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownMilestoneItem else {
            return false
        }
        
        return milestone == other.milestone
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? CountdownMilestoneItem else {
            return false
        }
        
        return milestone == other.milestone
    }
}

// MARK: - 里程碑集合单元格
/// 里程碑集合视图单元格
class CountdownMilestoneCollectionCell: TPDefaultInfoCollectionCell {
    
    static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
    
    /// 里程碑
    var milestoneItem: CountdownMilestoneItem? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        titleConfig.font = Self.titleFont
        titleConfig.textAlignment = .center
        titleConfig.selectedTextColor = .white
        subtitleConfig.font = .systemFont(ofSize: 12.0, weight: .medium)
        subtitleConfig.textAlignment = .center
        subtitleConfig.selectedTextColor = .white
        scaleWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTitle()
    }
    
    override func setChecked(_ checked: Bool, animated: Bool) {
        super.setChecked(checked, animated: animated)
        setNeedsLayout()
    }
    
    /// 更新标题
    func updateTitle() {
        guard let milestoneItem = milestoneItem else {
            infoView.title = nil
            infoView.subtitle = nil
            return
        }
        
        let milestone = milestoneItem.milestone
        infoView.title = milestone.title
        
        let targetDate = milestoneItem.date?.date(for: milestone)
        infoView.subtitle = targetDate?.displayText
    }
}

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
              selection.isSelectedItem(mileStone) else {
            return
        }
        
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
    private var itemPadding = UIEdgeInsets(horizontal: 8.0)
    
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
        cell.padding = itemPadding
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
