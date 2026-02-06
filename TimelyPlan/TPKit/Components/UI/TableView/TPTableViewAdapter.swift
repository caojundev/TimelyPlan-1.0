//
//  TPTableViewAdapter.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

class TPTableViewAdapter: NSObject,
                          UITableViewDataSource,
                          UITableViewDelegate {

    /// 数据源
    weak var dataSource: TPTableViewAdapterDataSource?

    /// 代理对象
    weak var delegate: TPTableViewAdapterDelegate?
    
    /// 默认单元格样式
    var cellStyle = TPTableCellStyle.defaultStyle()

    /// 适配器列表视图
    var tableView: UITableView! {
        didSet {
            registeredCellIdentifiers.removeAll()
            registeredHeaderFooterIdentifiers.removeAll()
            
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    /// 区块对象数组
    private(set) var objects: [ListDiffable] = []

    /// 保存区块对象对应的条目数组
    private var itemsMapTable: NSMapTable<AnyObject, NSArray>
    
    /// 已注册的单元格标识
    private var registeredCellIdentifiers: Set<String> = []
    
    /// 已注册的头脚视图标识
    private var registeredHeaderFooterIdentifiers: Set<String> = []
    
    override init() {
        let keyOptions: NSPointerFunctions.Options = [.objectPointerPersonality, .strongMemory]
        self.itemsMapTable = NSMapTable(keyOptions: keyOptions, valueOptions: .strongMemory)
        super.init()
    }

    // MARK: - Reload
    /// 重新加载数据
    func reloadData() {
        self.itemsMapTable.removeAllObjects()
        self.objects = getSectionObjects()
        for sectionObject in self.objects {
            let items = self.getItems(for: sectionObject)
            self.itemsMapTable.setObject(items as NSArray, forKey: sectionObject)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = objects[section]
        let items = items(for: object)
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cls: AnyClass = delegate?.adapter(self, classForCellAt: indexPath) ?? UITableViewCell.self
        let cell = dequeueReusableCell(cellClass: cls, identifier: nil, at: indexPath)
        cell.isHidden = false  /// 拖拽排序时Cell可能被隐藏

        if let cell = cell as? TPBaseTableCell {
            /// 设置样式
            var style = delegate?.adapter(self, styleForRowAt: indexPath)
            if style == nil {
                style = cellStyle
            }
            
            cell.style = style
        }
        
        if let cell = cell as? Checkable {
            let isChecked = delegate?.adapter(self, shouldShowCheckmarkForRowAt: indexPath) ?? false
            cell.isChecked = isChecked
        }
        
        delegate?.adapter(self, didDequeCell: cell, forRowAt: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerClass: AnyClass = delegate?.adapter(self, classForHeaderInSection: section) else {
            return nil
        }
        
        let headerView = dequeueHeaderView(viewClass: headerClass)
        delegate?.adapter(self, didDequeHeader: headerView, inSection: section)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerClass: AnyClass = delegate?.adapter(self, classForFooterInSection: section) else {
            return nil
        }
        
        let footerView = dequeueFooterView(viewClass: footerClass)
        delegate?.adapter(self, didDequeFooter: footerView, inSection: section)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegate?.adapter(self, heightForRowAt: indexPath) ?? 55.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return delegate?.adapter(self, heightForHeaderInSection: section) ?? 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return delegate?.adapter(self, heightForFooterInSection: section) ?? 0.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.adapter(self, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let bHighlight = delegate?.adapter(self, shouldHighlightRowAt: indexPath) ?? true
        return bHighlight
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return delegate?.adapter(self, editingStyleForRowAt: indexPath) ?? .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        delegate?.adapter(self, willBeginEditingRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return delegate?.adapter(self, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return delegate?.adapter(self, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.adapter(self, willDisplay: cell, forRowAt: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.adapter(self, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /// 手指拖动开始隐藏菜单
        let menuController = UIMenuController.shared
        if menuController.isMenuVisible {
            menuController.hideMenu()
        }
        
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
 
    // MARK: - Dequeue Reusable Views
    /// 获取单元格条目对应的复用标识
    @inline(__always)
    private func reusableViewIdentifier(viewClass: AnyClass, kind: String?, identifier: String?) -> String {
        let className = String(describing: viewClass.self)
        let kind = kind ?? ""
        let identifier = identifier ?? ""
        return className + kind + identifier
    }
    
    func dequeueReusableCell(cellClass: AnyClass,
                             identifier: String?,
                             at indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = reusableViewIdentifier(viewClass: cellClass, kind: "Cell", identifier: identifier)
        if !registeredCellIdentifiers.contains(reuseIdentifier) {
            tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
            registeredCellIdentifiers.insert(reuseIdentifier)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                             for: indexPath)
    }

    func dequeueReusableHeaderFooterView(viewClass: AnyClass,
                                         kind: String?) -> UITableViewHeaderFooterView {
        let reuseIdentifier = reusableViewIdentifier(viewClass: viewClass,
                                                     kind: kind,
                                                     identifier: nil)
        if !registeredHeaderFooterIdentifiers.contains(reuseIdentifier) {
            tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            registeredHeaderFooterIdentifiers.insert(reuseIdentifier)
        }
        
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)!
    }
        
    
    /// 头视图
    func dequeueHeaderView(viewClass: AnyClass) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(viewClass: viewClass, kind: "Header")
    }
    
    /// 脚视图
    func dequeueFooterView(viewClass: AnyClass) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(viewClass: viewClass, kind: "Footer")
    }
    
    // MARK: - DataSource Helpers
    private func getSectionObjects() -> [ListDiffable] {
        let objects = dataSource?.sectionObjects(for: self) ?? []
        return objects
    }
    
    private func getItems(for sectionObject: ListDiffable) -> [ListDiffable] {
        let items = dataSource?.adapter(self, itemsForSectionObject: sectionObject) ?? []
        return items
    }
    
    // MARK: - Section objects and items
    
    /// 区块对象对应的索引
    func section(of sectionObject: ListDiffable) -> Int? {
        return objects.indexOf(sectionObject)
    }
    
    func object(at index: Int) -> ListDiffable {
        return objects[index]
    }
    
    func items(for sectionObject: ListDiffable) -> [ListDiffable] {
        if let items = itemsMapTable.object(forKey: sectionObject) as? [ListDiffable] {
            return items
        }
        
        return []
    }
    
    func itemsCount(at section: Int) -> Int {
        let sectionObject = objects[section]
        let items = items(for: sectionObject)
        return items.count
    }
    
    func item(at indexPath: IndexPath) -> ListDiffable {
        let sectionObject = objects[indexPath.section]
        let items = items(for: sectionObject)
        return items[indexPath.item]
    }
    
    func indexPath(of item: ListDiffable) -> IndexPath? {
        for (section, object) in objects.enumerated() {
            let items = items(for: object)
            if let index = items.indexOf(item) {
                return IndexPath(item: index, section: section)
            }
        }
        
        return nil
    }
    
    /// 获取item的最新对象，因为两个不同的对象可能被判定为相等
    func item(of item: ListDiffable) -> ListDiffable? {
        for object in objects {
            let items = items(for: object)
            if let index = items.indexOf(item) {
                return items[index]
            }
        }
        
        return nil
    }
    
    /// 获取所有条目
    func allItems() -> [ListDiffable] {
        var results = [ListDiffable]()
        for object in objects {
            let items = items(for: object)
            results.append(contentsOf: items)
        }
        
        return results
    }
    
    /// 是否有条目
    var hasItem: Bool {
        for object in objects {
            let items = items(for: object)
            if items.count > 0 {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Update
extension TPTableViewAdapter {
    
    func performNilUpdate() {
        tableView.performBatchUpdates(nil, completion: nil)
    }
    
    func performUpdate(completion: ((Bool) -> Void)? = nil) {
        let rowAnimation = UITableView.RowAnimation.automatic
        performUpdate(with: rowAnimation, completion: completion)
    }
        
    func performUpdate(with rowAnimation: UITableView.RowAnimation, completion: ((Bool) -> Void)? = nil) {
        let oldObjects = self.objects
        let newObjects = getSectionObjects()
        self.objects = newObjects
  
        let sectionResult = ListDiff(oldArray: oldObjects, newArray: newObjects, option: .equality)
    
        /// 插入区块所对应的对象
        let insertObjects = newObjects.elementsAtIndexes(indexes: sectionResult.inserts)
        for insertObject in insertObjects {
            /// 更新条目数据
            let items = getItems(for: insertObject)
            itemsMapTable.setObject(items as NSArray, forKey: insertObject)
        }
        
        /// 更新区块所对应的对象
        var indexPathResults = [ListIndexPathResult]()
        var updateObjects = oldObjects
        updateObjects.removeElementsAtIndexes(indexes: sectionResult.deletes)
        for updateObject in updateObjects {
            let fromSection = oldObjects.indexOf(updateObject)
            let toSection = newObjects.indexOf(updateObject)
            guard let fromSection = fromSection, let toSection = toSection else {
                assert(false, "区块所对应的对象不存在")
                return
            }

            /// 获取旧区块条目数组
            let oldItems = items(for: updateObject)
            itemsMapTable.removeObject(forKey: updateObject)
            
            /// 获取新区块数据条目数组
            /// oldObjects 和 newObjects中的"object"可能不是同一对象，所以需要更新sectionController
            let updateObject = newObjects[toSection]
            let newItems = getItems(for: updateObject)
            itemsMapTable.setObject(newItems as NSArray, forKey: updateObject)
            
            let result = ListDiffPaths(fromSection: fromSection,
                                            toSection: toSection,
                                            oldArray: oldItems,
                                            newArray: newItems,
                                            option: .equality)
            if result.hasChanges {
                indexPathResults.append(result)
            }
        }
        
        /// 删除区块
        let deleteObjects = oldObjects.elementsAtIndexes(indexes: sectionResult.deletes)
        for deleteObject in deleteObjects {
            itemsMapTable.removeObject(forKey: deleteObject)
        }
        
        tableView.performBatchUpdates {
            self.tableView.deleteSections(sectionResult.deletes, with: rowAnimation)
            self.tableView.insertSections(sectionResult.inserts, with: rowAnimation)
            for move in sectionResult.moves {
                self.tableView.moveSection(move.from, toSection: move.to)
            }
            
            for result in indexPathResults {
                self.tableView.deleteRows(at: result.deletes, with: rowAnimation)
                self.tableView.insertRows(at: result.inserts, with: rowAnimation)
                self.tableView.reloadRows(at: result.updates, with: rowAnimation)
                for move in result.moves {
                    self.tableView.moveRow(at: move.from, to: move.to)
                }
            }
        } completion: { finished in
            completion?(finished)
        }
        
        updateHeaderFooterViews()
    }

    
    func performSectionUpdate(forSectionObject sectionObject: ListDiffable,
                              rowAnimation: UITableView.RowAnimation = .automatic) {
        performSectionUpdate(forSectionObjects: [sectionObject], rowAnimation: rowAnimation, completion: nil)
    }
    
    func performSectionUpdate(forSectionObject sectionObject: ListDiffable,
                              rowAnimation: UITableView.RowAnimation = .automatic,
                              completion: ((Bool) -> Void)?) {
        performSectionUpdate(forSectionObjects: [sectionObject],
                             rowAnimation: rowAnimation,
                             completion: completion)
    }
    
    func performSectionUpdate(forSectionObject sectionObject: ListDiffable, completion: ((Bool) -> Void)?) {
        performSectionUpdate(forSectionObjects: [sectionObject], completion: completion)
    }
    
    func performSectionUpdate(forSectionObjects sectionObjects: [ListDiffable], completion: ((Bool) -> Void)?) {
        performSectionUpdate(forSectionObjects: sectionObjects,
                             rowAnimation: .automatic,
                             completion: completion)
    }
    
    func performSectionUpdate(forSectionObjects sectionObjects: [ListDiffable], rowAnimation: UITableView.RowAnimation, completion: ((Bool) -> Void)?) {
        var indexPathResults = [ListIndexPathResult]()
        for sectionObject in sectionObjects {
            guard let section = objects.indexOf(sectionObject) else {
                continue
            }
            
            let oldItems = items(for: sectionObject)
            let newItems = getItems(for: sectionObject)
            itemsMapTable.setObject(newItems as NSArray, forKey: sectionObject)
            
            let result = ListDiffPaths(fromSection: section,
                                            toSection: section,
                                            oldArray: oldItems,
                                            newArray: newItems,
                                            option: .equality)
            if result.hasChanges {
                indexPathResults.append(result)
            }
            
            if indexPathResults.count == 0 {
                completion?(true)
                return
            }
            
            tableView.performBatchUpdates {
                for result in indexPathResults {
                    self.tableView.deleteRows(at: result.deletes, with: rowAnimation)
                    self.tableView.insertRows(at: result.inserts, with: rowAnimation)
                    self.tableView.reloadRows(at: result.updates, with: rowAnimation)
                    for move in result.moves {
                        self.tableView.moveRow(at: move.from, to: move.to)
                    }
                }
            } completion: { finished in
                completion?(finished)
            }
            
            updateHeaderFooterView(forSectionObjects: sectionObjects)
        }
    }
}

extension TPTableViewAdapter {
    
    // MARK: - header footer views
    func updateHeaderFooterViews() {
        for section in 0..<objects.count {
            delegate?.adapter(self, updateHeaderInSection: section)
            delegate?.adapter(self, updateFooterInSection: section)
        }
    }
    
    /// 更新特定区块对应的 Header Footer 视图
    func updateHeaderFooterView(forSectionObjects objects: [ListDiffable]) {
        for object in objects {
            updateHeaderFooterView(forSectionObject: object)
        }
    }
    
    func updateHeaderFooterView(forSectionObject object: ListDiffable) {
        guard let section = objects.indexOf(object) else {
            return
        }
        
        self.updateHeaderFooterView(of: section)
    }
    
    func updateHeaderFooterView(of section: Int) {
        self.updateHeaderView(of: section)
        self.updateFooterView(of: section)
    }
    
    func updateHeaderView(of section: Int) {
        delegate?.adapter(self, updateHeaderInSection: section)
    }
    
    func updateFooterView(of section: Int) {
        delegate?.adapter(self, updateFooterInSection: section)
    }
    
    // MARK: - Checkmarks
    func updateCheckmarks() {
        updateCheckmarks(animated: false)
    }

    func updateCheckmarks(animated: Bool) {
        let indexPaths = visibleIndexPaths()
        for indexPath in indexPaths {
            updateCheckmark(at: indexPath, animated: animated)
        }
    }

    func updateCheckmark(at indexPath: IndexPath) {
        updateCheckmark(at: indexPath, animated: false)
    }

    func updateCheckmark(at indexPath: IndexPath, animated: Bool) {
        guard let cell = cellForRow(at: indexPath) as? Checkable else {
            return
        }
        
        let isChecked = delegate?.adapter(self, shouldShowCheckmarkForRowAt: indexPath) ?? false
        cell.setChecked(isChecked, animated: animated)
    }
    
    func updateCheckmarks(for items: [ListDiffable], animated: Bool) {
        guard let indexPaths = indexPaths(of: items) else {
            return
        }
        
        for indexPath in indexPaths {
            updateCheckmark(at: indexPath, animated: animated)
        }
    }
    
}

// MARK: - Reload
extension TPTableViewAdapter {
    
    /// 重新加载特定区块对应的单元格条目
    func reloadCell(forItems items: [ListDiffable],
                    inSection sectionObject: ListDiffable,
                    rowAnimation: UITableView.RowAnimation,
                    animateFocus: Bool) {
        let sectionItems = self.items(for: sectionObject)
        guard sectionItems.count > 0, let section = section(of: sectionObject) else {
            return
        }
        
        var indexPaths = Set<IndexPath>()
        for item in items {
            if let index = sectionItems.indexOf(item) {
                let indexPath = IndexPath(item: index, section: section)
                indexPaths.insert(indexPath)
            }
        }
        
        reloadRows(at: indexPaths, with: rowAnimation, animateFocus: animateFocus)
    }
    
    /// 重新加载对象对应的区块
    func reloadSection(forObject object: ListDiffable) {
        reloadSection(forObject: object, with: .automatic)
    }
    
    func reloadSection(forObject object: ListDiffable, with rowAnimation: UITableView.RowAnimation) {
        if let index = objects.indexOf(object) {
            let sections = IndexSet(integer: index)
            tableView.reloadSections(sections, with: rowAnimation)
        }
    }
    
    func reloadSections(forObjects objects: [ListDiffable]) {
        reloadSections(forObjects: objects, with: .automatic)
    }
    
    func reloadSections(forObjects objects: [ListDiffable], with rowAnimation: UITableView.RowAnimation) {
        var sections = IndexSet()
        for object in objects {
            if let index = objects.indexOf(object) {
                sections.insert(index)
            }
        }
        
        if sections.count > 0 {
            tableView.reloadSections(sections, with: rowAnimation)
        }
    }
    
    /// 重新加载条目处对应的单元格
    func reloadCell(forItem item: ListDiffable) {
        reloadCell(forItem: item, with: .automatic, focusAnimated: false)
    }
    
    func reloadCell(forItem item: ListDiffable, with rowAnimation: UITableView.RowAnimation) {
        reloadCell(forItem: item, with: rowAnimation, focusAnimated: false)
    }
    
    func reloadCell(forItem item: ListDiffable, with rowAnimation: UITableView.RowAnimation, focusAnimated: Bool) {
        guard let indexPath = indexPath(of: item) else {
            return
        }
    
        reloadCell(at: indexPath, with: rowAnimation, focusAnimated: focusAnimated)
    }

    func reloadCell(forItems items: [ListDiffable]) {
        reloadCell(forItems: items, with: .automatic)
    }
    
    func reloadCell(forItems items: [ListDiffable], with rowAnimation: UITableView.RowAnimation) {
        reloadCell(forItems: items, with: rowAnimation, focusAnimated: false)
    }

    func reloadCell(forItems items: [ListDiffable],
                    with rowAnimation: UITableView.RowAnimation,
                    focusAnimated: Bool) {
        guard let indexPaths = indexPaths(of: items), indexPaths.count > 0 else {
            return
        }
    
        reloadRows(at: indexPaths, with: rowAnimation, animateFocus: focusAnimated)
    }
    
    func reloadCell(at indexPath: IndexPath,
                    with rowAnimation: UITableView.RowAnimation = .none,
                    focusAnimated: Bool = false) {
        tableView.reloadRows(at: [indexPath], with: rowAnimation)
        if focusAnimated {
            commitFocusAnimation(at: indexPath)
        }
    }
    
    func reloadRows(at indexPaths: Set<IndexPath>,
                    with rowAnimation: UITableView.RowAnimation,
                    animateFocus: Bool) {
        if indexPaths.count > 0 {
            tableView.reloadRows(at: Array(indexPaths), with: rowAnimation)
        }
        
        if animateFocus {
            for indexPath in indexPaths {
                commitFocusAnimation(at: indexPath)
            }
        }
    }
}


// MARK: - 滚动
extension TPTableViewAdapter {

    func scrollToItem(_ item: ListDiffable, at scrollPosition: UITableView.ScrollPosition, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let indexPath = indexPath(of: item) else {
            completion?(false)
            return
        }
        
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated, completion: completion)
    }
    
    func scrollToItem(_ item: ListDiffable,
                      inSection sectionObject: ListDiffable,
                      at scrollPosition: UITableView.ScrollPosition = .middle,
                      animated: Bool = true,
                      completion: ((Bool) -> Void)? = nil) {
        guard let indexPath = indexPath(of: item, inSection: sectionObject) else {
            completion?(false)
            return
        }
        
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated, completion: completion)
    }
    
    func scrollToRow(at indexPath: IndexPath,
                     at scrollPosition: UITableView.ScrollPosition = .middle,
                     animated: Bool = true,
                     completion: ((Bool) -> Void)? = nil) {
        tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        if !animated {
            completion?(true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                completion?(true)
            }
        }
    }
}

// MARK: - 聚焦动画
extension TPTableViewAdapter {
    
    func commitFocusAnimation(for item: ListDiffable) {
        if let indexPath = indexPath(of: item) {
            commitFocusAnimation(at: indexPath)
        }
    }

    func commitFocusAnimation(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FocusAnimatable else {
            return
        }
        
        /// 移除其它可见单元格的聚焦动画
//        if let cells = tableView.visibleCells as? [FocusAnimatable] {
//            for cell in cells {
//                cell.removeFocusAnimation()
//            }
//        }
        cell.commitFocusAnimation()
    }
}

// MARK: - 视图上下文信息
extension TPTableViewAdapter {
    
    // MARK: - Size
    func tableViewSize() -> CGSize {
        return tableView.frame.size
    }
    
    /// 获取单元格的宽度
    func tableViewCellWidth() -> CGFloat {
        let size = tableViewSize()
        
        /// 内间距
        var margins: UIEdgeInsets = .zero
        if tableView.style == .insetGrouped {
            margins = tableView.layoutMargins
        }
        
        return max(size.width - margins.horizontalLength, 0.0)
    }
    
    // MARK: - header footer views
    func headerView(in section: Int) -> UITableViewHeaderFooterView? {
        return tableView.headerView(forSection: section)
    }
    
    func footerView(in section: Int) -> UITableViewHeaderFooterView? {
        return tableView.footerView(forSection: section)
    }
    
    // MARK: - Cells
    func cellForItem(_ item: ListDiffable) -> UITableViewCell? {
        guard let indexPath = indexPath(of: item) else {
            return nil
        }
        
        return tableView.cellForRow(at: indexPath)
    }
    
    func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.cellForRow(at: indexPath)
    }

    func visibleCells() -> [UITableViewCell] {
        return tableView.visibleCells
    }
    
    // MARK: - IndexPath
    
    /// 区块对象对应的区块的可见单元格索引
    func visibleIndexPaths(forSectionObject object: ListDiffable) -> [IndexPath]? {
        guard let section = objects.indexOf(object) else {
            return nil
        }
    
        var indexPaths = [IndexPath]()
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else {
            return nil
        }
        
        for indexPath in visibleIndexPaths {
            if indexPath.section == section {
                indexPaths.append(indexPath)
            }
        }
        
        return indexPaths
    }

    func visibleIndexPaths() -> [IndexPath] {
        return tableView.indexPathsForVisibleRows ?? []
    }
    
    func indexPath(for cell: UITableViewCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
    
    func indexPath(of item: ListDiffable, inSection sectionObject: ListDiffable) -> IndexPath? {
        let sectionItems = self.items(for: sectionObject)
        guard sectionItems.count > 0, let section = section(of: sectionObject) else {
            return nil
        }
        
        if let index = sectionItems.indexOf(item) {
            return IndexPath(item: index, section: section)
        }
        
        return nil
    }

    func indexPaths(of items: [ListDiffable]) -> Set<IndexPath>? {
        var indexPaths = Set<IndexPath>()
        for item in items {
            if let indexPath = indexPath(of: item) {
                indexPaths.insert(indexPath)
            }
        }
            
        if indexPaths.count > 0 {
            return indexPaths
        }
        
        return nil
    }
}
