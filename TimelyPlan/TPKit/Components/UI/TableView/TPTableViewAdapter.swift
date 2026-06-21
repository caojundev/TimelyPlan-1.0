//
//  TPTableViewAdapter.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/27.
//

import Foundation
import UIKit

// MARK: - Constants
private enum TPTableViewAdapterConstants {
    static let defaultRowHeight: CGFloat = 55.0
    static let scrollAnimationDelay: TimeInterval = 0.4
    static let cellKind = "Cell"
    static let headerKind = "Header"
    static let footerKind = "Footer"
}

// MARK: - TPTableViewAdapter

class TPTableViewAdapter: NSObject,
                          UITableViewDataSource,
                          UITableViewDelegate {

    // MARK: - Properties
    
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
    
    /// Section 对象的索引映射（用于快速查找）
    private var sectionIndexMap: [ObjectIdentifier: Int] = [:]

    /// 保存区块对象对应的条目数组
    private var itemsMapTable: NSMapTable<AnyObject, NSArray>
    
    /// 已注册的单元格标识
    private var registeredCellIdentifiers: Set<String> = []
    
    /// 已注册的头脚视图标识
    private var registeredHeaderFooterIdentifiers: Set<String> = []
    
    // MARK: - Initialization
    
    override init() {
        let keyOptions: NSPointerFunctions.Options = [.objectPointerPersonality, .strongMemory]
        self.itemsMapTable = NSMapTable(keyOptions: keyOptions, valueOptions: .strongMemory)
        super.init()
    }

    // MARK: - Reload
    private(set) var needsReload: Bool = false
    
    func reloadDataIfNeeded() {
        if needsReload {
            needsReload = false
            reloadData()
        }
    }
    
    /// 重新加载数据
    func reloadData() {
        rebuildSectionIndexMap()
        itemsMapTable.removeAllObjects()
        objects = getSectionObjects()
        
        for sectionObject in objects {
            let items = getItems(for: sectionObject)
            itemsMapTable.setObject(items as NSArray, forKey: sectionObject)
        }
        
        tableView.reloadData()
    }
    
    /// 重建 Section 索引映射
    private func rebuildSectionIndexMap() {
        sectionIndexMap.removeAll()
        for (index, object) in objects.enumerated() {
            sectionIndexMap[ObjectIdentifier(object)] = index
        }
    }
    
    // MARK: - Update Visible Cells
    
    func updateVisibleCells() {
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                delegate?.adapter(self, didDequeCell: cell, forRowAt: indexPath)
            }
        }
    }
    
    func updateVisibleCells(forSectionObjects objects: [ListDiffable]) {
        for object in objects {
            updateVisibleCells(forSectionObject: object)
        }
    }
    
    func updateVisibleCells(forSectionObject object: ListDiffable) {
        guard let section = section(of: object),
              let indexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        
        for indexPath in indexPaths where indexPath.section == section {
            if let cell = tableView.cellForRow(at: indexPath) {
                delegate?.adapter(self, didDequeCell: cell, forRowAt: indexPath)
            }
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let object = objects[section]
        return items(for: object).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellClass: AnyClass = delegate?.adapter(self, classForCellAt: indexPath) ?? UITableViewCell.self
        let cell = dequeueReusableCell(cellClass: cellClass, identifier: nil, at: indexPath)
        cell.isHidden = false  // 拖拽排序时 Cell 可能被隐藏

        // 设置样式
        if let cell = cell as? TPBaseTableCell {
            let style = delegate?.adapter(self, styleForRowAt: indexPath) ?? cellStyle
            cell.style = style
        }
        
        // 配置选中状态
        if let cell = cell as? Checkable {
            let isChecked = delegate?.adapter(self, shouldShowCheckmarkForRowAt: indexPath) ?? false
            cell.isChecked = isChecked
        }
        
        delegate?.adapter(self, didDequeCell: cell, forRowAt: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerClass = delegate?.adapter(self, classForHeaderInSection: section) else {
            return nil
        }
        
        let headerView = dequeueHeaderView(viewClass: headerClass)
        delegate?.adapter(self, didDequeHeader: headerView, inSection: section)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerClass = delegate?.adapter(self, classForFooterInSection: section) else {
            return nil
        }
        
        let footerView = dequeueFooterView(viewClass: footerClass)
        delegate?.adapter(self, didDequeFooter: footerView, inSection: section)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegate?.adapter(self, heightForRowAt: indexPath) ?? TPTableViewAdapterConstants.defaultRowHeight
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
        return delegate?.adapter(self, shouldHighlightRowAt: indexPath) ?? true
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
        // 手指拖动开始隐藏菜单
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
    
    /// 获取复用视图标识符
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
        let reuseIdentifier = reusableViewIdentifier(
            viewClass: cellClass,
            kind: TPTableViewAdapterConstants.cellKind,
            identifier: identifier
        )
        
        if !registeredCellIdentifiers.contains(reuseIdentifier) {
            tableView.register(cellClass, forCellReuseIdentifier: reuseIdentifier)
            registeredCellIdentifiers.insert(reuseIdentifier)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
    }

    func dequeueReusableHeaderFooterView(viewClass: AnyClass,
                                         kind: String?) -> UITableViewHeaderFooterView {
        let reuseIdentifier = reusableViewIdentifier(
            viewClass: viewClass,
            kind: kind,
            identifier: nil
        )
        
        if !registeredHeaderFooterIdentifiers.contains(reuseIdentifier) {
            tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            registeredHeaderFooterIdentifiers.insert(reuseIdentifier)
        }
        
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) else {
            fatalError("Failed to dequeue header/footer view with identifier: \(reuseIdentifier)")
        }
        return view
    }
    
    /// 获取头视图
    func dequeueHeaderView(viewClass: AnyClass) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(viewClass: viewClass, kind: TPTableViewAdapterConstants.headerKind)
    }
    
    /// 获取脚视图
    func dequeueFooterView(viewClass: AnyClass) -> UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(viewClass: viewClass, kind: TPTableViewAdapterConstants.footerKind)
    }
    
    // MARK: - DataSource Helpers
    
    private func getSectionObjects() -> [ListDiffable] {
        return dataSource?.sectionObjects(for: self) ?? []
    }
    
    private func getItems(for sectionObject: ListDiffable) -> [ListDiffable] {
        return dataSource?.adapter(self, itemsForSectionObject: sectionObject) ?? []
    }
    
    // MARK: - Section Objects and Items
    
    /// 获取区块对象对应的索引
    func section(of sectionObject: ListDiffable) -> Int? {
        // 先尝试从缓存的索引映射中获取
        if let index = sectionIndexMap[ObjectIdentifier(sectionObject)] {
            return index
        }
        
        // 回退到线性搜索并更新缓存
        if let index = objects.indexOf(sectionObject) {
            rebuildSectionIndexMap()
            return index
        }
        
        return nil
    }
    
    func object(at index: Int) -> ListDiffable {
        return objects[index]
    }
    
    func items(for sectionObject: ListDiffable) -> [ListDiffable] {
        return itemsMapTable.object(forKey: sectionObject) as? [ListDiffable] ?? []
    }
    
    func itemsCount(at section: Int) -> Int {
        let sectionObject = objects[section]
        return items(for: sectionObject).count
    }
    
    func item(at indexPath: IndexPath) -> ListDiffable {
        let sectionObject = objects[indexPath.section]
        return items(for: sectionObject)[indexPath.item]
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
    
    /// 获取 item 的最新对象（因为两个不同的对象可能被判定为相等）
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
        return objects.flatMap { items(for: $0) }
    }
    
    /// 是否有条目
    var hasItem: Bool {
        return objects.contains { !items(for: $0).isEmpty }
    }
    
    /// 移动单元格条目
    func moveRow(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        if fromIndexPath.section == toIndexPath.section {
            // 相同区块内移动
            let sectionObject = object(at: fromIndexPath.section)
            var sectionItems = items(for: sectionObject)
            sectionItems.moveObject(fromIndex: fromIndexPath.item, toIndex: toIndexPath.item)
            itemsMapTable.setObject(sectionItems as NSArray, forKey: sectionObject)
        } else {
            // 跨区块移动
            let fromSectionObject = object(at: fromIndexPath.section)
            var fromSectionItems = items(for: fromSectionObject)
            let item = fromSectionItems.remove(at: fromIndexPath.item)
            itemsMapTable.setObject(fromSectionItems as NSArray, forKey: fromSectionObject)
            
            let toSectionObject = object(at: toIndexPath.section)
            var toSectionItems = items(for: toSectionObject)
            toSectionItems.insert(item, at: toIndexPath.item)
            itemsMapTable.setObject(toSectionItems as NSArray, forKey: toSectionObject)
        }
        
        tableView.moveRow(at: fromIndexPath, to: toIndexPath)
    }
}

// MARK: - Update

extension TPTableViewAdapter {
    
    func performNilUpdate() {
        tableView.performBatchUpdates(nil, completion: nil)
    }
        
    func performUpdate(with rowAnimation: UITableView.RowAnimation = .automatic,
                       completion: ((Bool) -> Void)? = nil) {
        guard tableView.window != nil else {
            needsReload = true
            completion?(true)
            return
        }
        
        if !hasItem {
            /// 空白列表，直接重新加载数据
            reloadData()
            completion?(true)
            return
        }
        
        let oldObjects = objects
        let newObjects = getSectionObjects()
        objects = newObjects
        rebuildSectionIndexMap()
  
        let sectionResult = ListDiff(oldArray: oldObjects, newArray: newObjects, option: .equality)
    
        // 插入区块所对应的对象
        let insertObjects = newObjects.elementsAtIndexes(indexes: sectionResult.inserts)
        for insertObject in insertObjects {
            let items = getItems(for: insertObject)
            itemsMapTable.setObject(items as NSArray, forKey: insertObject)
        }
        
        // 更新区块所对应的对象
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

            // 获取旧区块条目数组
            let oldItems = items(for: updateObject)
            itemsMapTable.removeObject(forKey: updateObject)
            
            // 获取新区块数据条目数组
            // oldObjects 和 newObjects 中的 "object" 可能不是同一对象，所以需要更新 sectionController
            let updateObject = newObjects[toSection]
            let newItems = getItems(for: updateObject)
            itemsMapTable.setObject(newItems as NSArray, forKey: updateObject)
            
            let result = ListDiffPaths(
                fromSection: fromSection,
                toSection: toSection,
                oldArray: oldItems,
                newArray: newItems,
                option: .equality
            )
            if result.hasChanges {
                indexPathResults.append(result)
            }
        }
        
        // 删除区块
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
                for move in result.moves {
                    self.tableView.moveRow(at: move.from, to: move.to)
                }
            }
        } completion: { finished in
            completion?(finished)
        }
        
        updateVisibleCells()
        updateHeaderFooterViews()
    }
    
    // MARK: - Section Update
    
    func performSectionUpdate(forSectionObject sectionObject: ListDiffable,
                              rowAnimation: UITableView.RowAnimation = .automatic,
                              completion: ((Bool) -> Void)? = nil) {
        performSectionUpdate(forSectionObjects: [sectionObject],
                             rowAnimation: rowAnimation,
                             completion: completion)
    }
    
    func performSectionUpdate(forSectionObjects sectionObjects: [ListDiffable],
                              rowAnimation: UITableView.RowAnimation = .automatic,
                              completion: ((Bool) -> Void)? = nil) {
        guard tableView.window != nil else {
            needsReload = true
            completion?(true)
            return
        }
        
        var indexPathResults = [ListIndexPathResult]()
        for sectionObject in sectionObjects {
            guard let section = section(of: sectionObject) else {
                continue
            }
            
            let oldItems = items(for: sectionObject)
            let newItems = getItems(for: sectionObject)
            itemsMapTable.setObject(newItems as NSArray, forKey: sectionObject)
            
            let result = ListDiffPaths(
                fromSection: section,
                toSection: section,
                oldArray: oldItems,
                newArray: newItems,
                option: .equality
            )
            if result.hasChanges {
                indexPathResults.append(result)
            }
        }
        
        if indexPathResults.isEmpty {
            updateVisibleCells(forSectionObjects: sectionObjects)
            updateHeaderFooterView(forSectionObjects: sectionObjects)
            completion?(true)
            return
        }
        
        let updates = {
            for result in indexPathResults {
                self.tableView.deleteRows(at: result.deletes, with: rowAnimation)
                self.tableView.insertRows(at: result.inserts, with: rowAnimation)
                for move in result.moves {
                    self.tableView.moveRow(at: move.from, to: move.to)
                }
            }
        }
        
        if rowAnimation == .none {
            UIView.performWithoutAnimation {
                self.tableView.performBatchUpdates(updates, completion: nil)
            }
            
            updateVisibleCells(forSectionObjects: sectionObjects)
            updateHeaderFooterView(forSectionObjects: sectionObjects)
            completion?(true)
        } else {
            self.tableView.performBatchUpdates(updates, completion: completion)
            updateVisibleCells(forSectionObjects: sectionObjects)
            updateHeaderFooterView(forSectionObjects: sectionObjects)
        }
    }
}

extension TPTableViewAdapter {
    
    // MARK: - Header Footer Views
    
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
        guard let section = section(of: object) else {
            return
        }
        updateHeaderFooterView(of: section)
    }
    
    func updateHeaderFooterView(of section: Int) {
        updateHeaderView(of: section)
        updateFooterView(of: section)
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
        for indexPath in visibleIndexPaths() {
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
        guard !sectionItems.isEmpty, let section = section(of: sectionObject) else {
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
        guard let index = section(of: object) else { return }
        tableView.reloadSections(IndexSet(integer: index), with: rowAnimation)
    }
    
    func reloadSections(forObjects objects: [ListDiffable]) {
        reloadSections(forObjects: objects, with: .automatic)
    }
    
    func reloadSections(forObjects objects: [ListDiffable], with rowAnimation: UITableView.RowAnimation) {
        var sections = IndexSet()
        for object in objects {
            if let index = section(of: object) {
                sections.insert(index)
            }
        }
        
        if !sections.isEmpty {
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
    
    func reloadCell(forItem item: ListDiffable,
                    with rowAnimation: UITableView.RowAnimation,
                    focusAnimated: Bool) {
        guard let indexPath = indexPath(of: item) else { return }
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
        guard let indexPaths = indexPaths(of: items), !indexPaths.isEmpty else {
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
        if !indexPaths.isEmpty {
            tableView.reloadRows(at: Array(indexPaths), with: rowAnimation)
        }
        
        if animateFocus {
            for indexPath in indexPaths {
                commitFocusAnimation(at: indexPath)
            }
        }
    }
}


// MARK: - Scroll

extension TPTableViewAdapter {

    func scrollToItem(_ item: ListDiffable,
                      at scrollPosition: UITableView.ScrollPosition,
                      animated: Bool,
                      completion: ((Bool) -> Void)? = nil) {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + TPTableViewAdapterConstants.scrollAnimationDelay) {
                completion?(true)
            }
        }
    }
}

// MARK: - Focus Animation

extension TPTableViewAdapter {
    
    /// 聚焦显示
    func revealItem(_ item: ListDiffable,
                    at scrollPosition: UITableView.ScrollPosition = .middle,
                    autoScroll: Bool = true) {
        if autoScroll {
            scrollToItem(item, at: scrollPosition, animated: true) { [weak self] _ in
                self?.commitFocusAnimation(for: item)
            }
        } else {
            commitFocusAnimation(for: item)
        }
    }
    
    func revealItemAutoScrollIfNeeded(_ item: ListDiffable,
                                      at scrollPosition: UITableView.ScrollPosition = .middle) {
        guard tableView.window != nil else {
            return
        }
        
        if let cell = cellForItem(item) {
            if let cell = cell as? FocusAnimatable {
                cell.commitFocusAnimation()
            }
            
            return
        }
        
        scrollToItem(item, at: scrollPosition, animated: true) { [weak self] _ in
            self?.commitFocusAnimation(for: item)
        }
    }
    
    func commitFocusAnimation(for item: ListDiffable) {
        guard tableView.window != nil else {
            return
        }
        
        if let indexPath = indexPath(of: item) {
            commitFocusAnimation(at: indexPath)
        }
    }

    func commitFocusAnimation(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FocusAnimatable else {
            return
        }
        
        cell.commitFocusAnimation()
    }
}

// MARK: - View Context Information

extension TPTableViewAdapter {
    
    // MARK: - Size
    
    func tableViewSize() -> CGSize {
        return tableView.frame.size
    }
    
    /// 获取单元格的宽度
    func tableViewCellWidth() -> CGFloat {
        let size = tableViewSize()
        
        // 内间距
        var margins: UIEdgeInsets = .zero
        if tableView.style == .insetGrouped {
            margins = tableView.layoutMargins
        }
        
        return max(size.width - margins.horizontalLength, 0.0)
    }
    
    // MARK: - Header Footer Views
    
    func headerView(in section: Int) -> UITableViewHeaderFooterView? {
        return tableView.headerView(forSection: section)
    }
    
    func footerView(in section: Int) -> UITableViewHeaderFooterView? {
        return tableView.footerView(forSection: section)
    }
    
    // MARK: - Cells
    func cellForItem(_ item: ListDiffable) -> UITableViewCell? {
        guard let indexPath = indexPath(of: item) else { return nil }
        return tableView.cellForRow(at: indexPath)
    }
    
    func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.cellForRow(at: indexPath)
    }

    var visibleCells: [UITableViewCell] {
        return tableView.visibleCells
    }
    
    // MARK: - IndexPath
    
    /// 区块对象对应的区块的可见单元格索引
    func visibleIndexPaths(forSectionObject object: ListDiffable) -> [IndexPath]? {
        guard let section = section(of: object),
              let visibleIndexPaths = tableView.indexPathsForVisibleRows else {
            return nil
        }
    
        return visibleIndexPaths.filter { $0.section == section }
    }

    func visibleIndexPaths() -> [IndexPath] {
        return tableView.indexPathsForVisibleRows ?? []
    }
    
    func indexPath(for cell: UITableViewCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
    func indexPath(of item: ListDiffable, inSection sectionObject: ListDiffable) -> IndexPath? {
        let sectionItems = items(for: sectionObject)
        guard !sectionItems.isEmpty, let section = section(of: sectionObject) else {
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
        
        return indexPaths.isEmpty ? nil : indexPaths
    }
    
    
    func cellForItem(with diffIdentifier: NSObjectProtocol,
                     inSection sectionObject: ListDiffable) -> UITableViewCell? {
        guard let indexPath = indexPathForItem(with: diffIdentifier, inSection: sectionObject) else {
            return nil
        }
        
        return tableView.cellForRow(at: indexPath)
    }
    
    func indexPathForItem(with diffIdentifier: NSObjectProtocol,
                          inSection sectionObject: ListDiffable) -> IndexPath? {
        let sectionItems = items(for: sectionObject)
        guard !sectionItems.isEmpty, let section = section(of: sectionObject) else {
            return nil
        }
        
        for (index, item) in sectionItems.enumerated() {
            let identifier = item.diffIdentifier()
            if diffIdentifier.isEqual(identifier) {
                return IndexPath(item: index, section: section)
            }
        }
        
        return nil
    }
}
