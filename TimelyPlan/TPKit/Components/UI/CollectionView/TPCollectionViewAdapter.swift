//
//  TPCollectionViewAdapter.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/7.
//

import Foundation
import UIKit

class TPCollectionViewAdapter: NSObject,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate,
                                 UICollectionViewDelegateFlowLayout {

    weak var dataSource: TPCollectionViewAdapterDataSource?

    weak var delegate: TPCollectionViewAdapterDelegate?
    
    /// 适配器列表视图
    var collectionView: UICollectionView! {
        didSet {
            /// 不同的集合视图，移除原有的注册标识
            registeredCellIdentifiers.removeAll()
            registeredSupplementaryViewIdentifiers.removeAll()
            
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    /// 是否可以编辑
    var editEnabled: Bool = false
    
    /// 区块内间距
    var sectionInset: UIEdgeInsets = .zero
    
    /// 行间距
    var lineSpacing: CGFloat = 0.0
    
    /// 条目间距
    var interitemSpacing: CGFloat = 0.0
    
    /// 单元格注册类
    var cellClass: AnyClass = TPCollectionCell.self
    
    /// 单元格尺寸
    var cellSize: CGSize = .zero
    
    /// 单元格内间距
    var cellPadding: UIEdgeInsets = .zero
    
    /// header
    var headerSize: CGSize = .zero
    var headerClass: AnyClass = TPCollectionHeaderFooterView.self
    
    /// footer
    var footerSize: CGSize = .zero
    var footerClass: AnyClass = TPCollectionHeaderFooterView.self

    /// 默认单元格样式
    lazy var cellStyle: TPCollectionCellStyle = {
        let style = TPCollectionCellStyle()
        style.backgroundColor = Color(light: 0x1B225C, 0.1, dark: 0x1B1B23, 1.0)
        style.selectedBackgroundColor = style.backgroundColor
        return style
    }()

    /// 区块对象数组
    private(set) var objects: [ListDiffable] = []

    /// 保存区块对象对应的条目数组
    private var itemsMapTable: NSMapTable<AnyObject, NSArray>
    
    /// 已注册的单元格标识
    private var registeredCellIdentifiers: Set<String> = []
    
    /// 已注册的补充视图标识
    private var registeredSupplementaryViewIdentifiers: Set<String> = []
    
    override init() {
        let keyOptions: NSPointerFunctions.Options = [.objectPointerPersonality, .strongMemory]
        self.itemsMapTable = NSMapTable(keyOptions: keyOptions, valueOptions: .strongMemory)
        super.init()
    }

    // MARK: - Reload
    /// 重新加载数据
    func reloadData() {
        itemsMapTable.removeAllObjects()
        objects = fetchSectionObjects()
        for sectionObject in objects {
            let items = fetchItems(for: sectionObject)
            itemsMapTable.setObject(items as NSArray, forKey: sectionObject)
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let object = objects[section]
        let items = items(for: object)
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cls: AnyClass = delegate?.adapter(self, classForCellAt: indexPath) ?? UICollectionViewCell.self
        let cell = dequeueReusableCell(cellClass: cls, identifier: nil, at: indexPath)
        cell.isHidden = false  /// 拖拽排序时Cell可能被隐藏
        
        if let cell = cell as? Checkable {
            /// 是否选中
            cell.isChecked = delegate?.adapter(self, shouldShowCheckmarkForItemAt: indexPath) ?? false
        }
        
        cell.padding = cellPadding
        if let cell = cell as? TPCollectionCell {
            cell.cellStyle = cellStyle
        }
        
        delegate?.adapter(self, didDequeCell: cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        if kind == UICollectionView.elementKindSectionHeader {
            let cls: AnyClass = delegate?.adapter(self, classForHeaderInSection: section) ?? UICollectionReusableView.self
            let headerView = dequeueHeaderView(viewClass: cls, at: section)
            delegate?.adapter(self, didDequeHeader: headerView, inSection: section)
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            let cls: AnyClass = delegate?.adapter(self, classForFooterInSection: section) ?? UICollectionReusableView.self
            let footerView = dequeueFooterView(viewClass: cls, at: section)
            delegate?.adapter(self, didDequeFooter: footerView, inSection: section)
            return footerView
        }
  
        let cls = UICollectionReusableView.self
        return dequeueReusableSupplementaryView(viewClass: cls,
                                                elementKind: kind,
                                                identifier: nil,
                                                for: indexPath)
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.adapter(self, didSelectItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let bHighlight = delegate?.adapter(self, shouldHighlightItemAt: indexPath) ?? true
        return bHighlight
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.removeFocusAnimation()
        delegate?.adapter(self, willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.adapter(self, didEndDisplaying: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        ///< 解决 header 挡住滚动条
        if elementKind == UICollectionView.elementKindSectionHeader {
            view.layer.zPosition = 0
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return delegate?.adapter(self, sizeForItemAt: indexPath) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return delegate?.adapter(self, insetForSectionAt: section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return delegate?.adapter(self, lineSpacingForSectionAt: section) ?? 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return delegate?.adapter(self, interitemSpacingForSectionAt: section) ?? 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return delegate?.adapter(self, sizeForHeaderInSection: section) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return delegate?.adapter(self, sizeForFooterInSection: section) ?? .zero
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView,
                                             withVelocity: velocity,
                                             targetContentOffset: targetContentOffset)
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
                             at indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = reusableViewIdentifier(viewClass: cellClass, kind: "Cell", identifier: identifier)
        if !registeredCellIdentifiers.contains(identifier) {
            collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
            registeredCellIdentifiers.insert(identifier)
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    func dequeueReusableSupplementaryView(viewClass: AnyClass,
                                          elementKind: String,
                                          identifier: String?,
                                          for indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = reusableViewIdentifier(viewClass: viewClass, kind: elementKind, identifier: identifier)
        if !registeredSupplementaryViewIdentifiers.contains(identifier) {
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
            registeredSupplementaryViewIdentifiers.insert(identifier)
        }
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind,
                                                               withReuseIdentifier: identifier,
                                                               for: indexPath)
    }

    /// 头视图
    func dequeueHeaderView(viewClass: AnyClass, at section: Int) -> UICollectionReusableView {
        let kind = UICollectionView.elementKindSectionHeader
        let indexPath = IndexPath(item: 0, section: section)
        return dequeueReusableSupplementaryView(viewClass: viewClass,
                                                elementKind: kind,
                                                identifier: nil,
                                                for: indexPath)
    }
    
    /// 脚视图
    func dequeueFooterView(viewClass: AnyClass, at section: Int) -> UICollectionReusableView {
        let kind = UICollectionView.elementKindSectionFooter
        let indexPath = IndexPath(item: 0, section: section)
        return dequeueReusableSupplementaryView(viewClass: viewClass,
                                                elementKind: kind,
                                                identifier: nil,
                                                for: indexPath)
    }
 
    // MARK: - Items
    
    /// 是否有数据条目
    func hasItem() -> Bool {
        for object in objects {
            let items = items(for: object)
            if items.count > 0 {
                return true
            }
        }
        
        return false
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
    
    func items(for sectionObject: AnyObject) -> [ListDiffable] {
        if let items = itemsMapTable.object(forKey: sectionObject) as? [ListDiffable] {
            return items
        }
        
        return []
    }
    
    func section(of object: ListDiffable) -> Int? {
        return objects.indexOf(object)
    }
    
    func object(at index: Int) -> ListDiffable {
        return objects[index]
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
}

// MARK: - Reload
extension TPCollectionViewAdapter {
    
    /// 重新加载条目处对应的单元格
    func reloadCell(forItem item: ListDiffable, focusAnimated: Bool = false) {
        if let indexPath = indexPath(of: item) {
            reloadCell(at: indexPath, focusAnimated: focusAnimated)
        }
    }
    
    func reloadCell(at indexPath: IndexPath, focusAnimated: Bool = false) {
        collectionView.reloadItems(at: [indexPath])
        if focusAnimated {
            commitFocusAnimation(at: indexPath)
        }
    }
    
    
    func reloadCell(forItems items: [ListDiffable]) {
        var indexPaths = [IndexPath]()
        for item in items {
            if let indexPath = indexPath(of: item) {
                indexPaths.append(indexPath)
            }
        }
        
        if indexPaths.count > 0 {
            collectionView.reloadItems(at: indexPaths)
        }
    }
    
    /// 移动单元格条目
    func moveItem(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        if fromIndexPath.section == toIndexPath.section {
            /// 相同区块
            let sectionObject = object(at: fromIndexPath.section)
            var sectionItems = items(for: sectionObject)
            sectionItems.moveObject(fromIndex: fromIndexPath.item, toIndex: toIndexPath.item)
            itemsMapTable.setObject(sectionItems as NSArray, forKey: sectionObject)
        } else {
            /// 不同区块
            let fromSectionObject = object(at: fromIndexPath.section)
            var fromSectionItems = items(for: fromSectionObject)
            let item = fromSectionItems.remove(at: fromIndexPath.item)
            itemsMapTable.setObject(fromSectionItems as NSArray, forKey: fromSectionObject)
            
            let toSectionObject = object(at: toIndexPath.section)
            var toSectionItems = items(for: toSectionObject)
            toSectionItems.insert(item, at: toIndexPath.item)
            itemsMapTable.setObject(toSectionItems as NSArray, forKey: toSectionObject)
        }
        
        collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
    }
}

// MARK: - 滚动
extension TPCollectionViewAdapter {
    
    // MARK: - Scroll
    func scrollToItem(_ item: ListDiffable, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        scrollToItem(item, at: scrollPosition, animated: animated, completion: nil)
    }

    func scrollToItem(_ item: ListDiffable, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            guard let indexPath = self.indexPath(of: item) else {
                completion?(false)
                return
            }

            self.collectionView.scrollToItem(at: indexPath,
                                             at: scrollPosition,
                                             animated: animated)
            if !animated {
                completion?(true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    completion?(true)
                }
            }
        }
    }
    
    func scrollToItem(at indexPath: IndexPath,
                      scrollPosition: UICollectionView.ScrollPosition,
                      animated: Bool,
                      completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath,
                                             at: scrollPosition,
                                             animated: animated)
            if !animated {
                completion?(true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    completion?(true)
                }
            }
        }
    }
}

// MARK: - 聚焦动画
extension TPCollectionViewAdapter {
    func commitFocusAnimation(for item: ListDiffable) {
        if let indexPath = indexPath(of: item) {
            commitFocusAnimation(at: indexPath)
        }
    }

    func commitFocusAnimation(at indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) as? FocusAnimatable else {
            return
        }
        
        /// 移除其它可见单元格的聚焦动画
        if let cells = collectionView.visibleCells as? [FocusAnimatable] {
            for cell in cells {
                cell.removeFocusAnimation()
            }
        }
        
        cell.commitFocusAnimation()
    }
}

// MARK: - Update Checkmark
extension TPCollectionViewAdapter {
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
        guard let cell = cellForItem(at: indexPath) as? Checkable else {
            return
        }
        
        let isChecked = delegate?.adapter(self, shouldShowCheckmarkForItemAt: indexPath) ?? false
        cell.setChecked(isChecked, animated: animated)
    }
}

// MARK: - PerformUpdate
extension TPCollectionViewAdapter {
    
    func performNilUpdate() {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func performUpdate() {
        performUpdate(with: nil)
    }
    
    func performUpdate(with completion: ((Bool) -> Void)?) {
        let oldObjects = self.objects
        let newObjects = fetchSectionObjects()
        self.objects = newObjects
  
        let sectionResult = ListDiff(oldArray: oldObjects, newArray: newObjects, option: .equality)
    
        /// 插入区块所对应的对象
        let insertObjects = newObjects.elementsAtIndexes(indexes: sectionResult.inserts)
        for insertObject in insertObjects {
            /// 更新条目数据
            let items = fetchItems(for: insertObject)
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
            let newItems = fetchItems(for: updateObject)
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
        
        collectionView.performBatchUpdates {
            self.collectionView.deleteSections(sectionResult.deletes)
            self.collectionView.insertSections(sectionResult.inserts)
            for move in sectionResult.moves {
                self.collectionView.moveSection(move.from, toSection: move.to)
            }
            
            for result in indexPathResults {
                self.collectionView.deleteItems(at: result.deletes)
                self.collectionView.insertItems(at: result.inserts)
                self.collectionView.reloadItems(at: result.updates)
                for move in result.moves {
                    self.collectionView.moveItem(at: move.from, to: move.to)
                }
            }
        } completion: { finished in
            completion?(finished)
        }
        
        updateVisibleHeaderFooterViews()
    }
    
    func performSectionUpdate(forSectionObject sectionObject: ListDiffable) {
        performSectionUpdate(forSectionObjects: [sectionObject], completion: nil)
    }
    
    func performSectionUpdate(forSectionObject sectionObject: ListDiffable, completion: ((Bool) -> Void)?) {
        performSectionUpdate(forSectionObjects: [sectionObject], completion: completion)
    }
    
    func performSectionUpdate(forSectionObjects sectionObjects: [ListDiffable], completion: ((Bool) -> Void)?) {
        var indexPathResults = [ListIndexPathResult]()
        for sectionObject in sectionObjects {
            guard let section = objects.indexOf(sectionObject) else {
                continue
            }
            
            let oldItems = items(for: sectionObject)
            let newItems = fetchItems(for: sectionObject)
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
            
            collectionView.performBatchUpdates {
                for result in indexPathResults {
                    self.collectionView.deleteItems(at: result.deletes)
                    self.collectionView.insertItems(at: result.inserts)
                    self.collectionView.reloadItems(at: result.updates)
                    for move in result.moves {
                        self.collectionView.moveItem(at: move.from, to: move.to)
                    }
                }
            } completion: { finished in
                completion?(finished)
            }
            
            updateHeaderFooterView(forSectionObjects: sectionObjects)
        }
    }
}

// MARK: - 更新 Header Footer 视图
extension TPCollectionViewAdapter {
    
    /// 更新所有头脚视图
    func updateHeaderFooterViews() {
        for section in 0..<objects.count {
            delegate?.adapter(self, updateHeaderInSection: section)
            delegate?.adapter(self, updateFooterInSection: section)
        }
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
    
    /// 可见 HeaderView 索引
    func visibleHeaderSections() -> IndexSet {
        let indexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
        var sections = IndexSet()
        for indexPath in indexPaths {
            sections.insert(indexPath.section)
        }
        
        return sections
    }

    /// 可见 FooterView 索引
    func visibleFooterSections() -> IndexSet {
        let indexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter)
        var sections = IndexSet()
        for indexPath in indexPaths {
            sections.insert(indexPath.section)
        }
        
        return sections
    }

    /// 更新可见 Header Footer 视图
    func updateVisibleHeaderFooterViews() {
        let headerSections = visibleHeaderSections()
        headerSections.forEach { section in
            delegate?.adapter(self, updateHeaderInSection: section)
        }
    
        let footerSections = visibleFooterSections()
        footerSections.forEach { section in
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
        
        delegate?.adapter(self, updateHeaderInSection: section)
        delegate?.adapter(self, updateFooterInSection: section)
    }
}

// MARK: - 视图上下文信息
extension TPCollectionViewAdapter {
    
    func collectionViewSize() -> CGSize {
        return collectionView.frame.size
    }
    
    var collectionContentSize: CGSize {
        return collectionView.contentSize
    }
    
    var scrollDirection: UICollectionView.ScrollDirection {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.scrollDirection
        }
        
        return .vertical
    }
    
    func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
        return collectionView.indexPath(for: cell)
    }
    
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        return collectionView.cellForItem(at: indexPath)
    }
    
    func cellForItem(_ item: ListDiffable) -> UICollectionViewCell? {
        guard let indexPath = indexPath(of: item) else {
            return nil
        }
        
        return collectionView.cellForItem(at: indexPath)
    }
    
    func headerView(in section: Int) -> UICollectionReusableView? {
        let indexPath = IndexPath(item: 0, section: section)
        return collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath)
    }
    
    func footerView(in section: Int) -> UICollectionReusableView? {
        let indexPath = IndexPath(item: 0, section: section)
        return collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: indexPath)
    }
    
    /// 区块对象对应的区块的可见单元格索引
    func visibleIndexPaths(forSectionObject object: ListDiffable) -> [IndexPath]? {
        guard let section = objects.indexOf(object) else {
            return nil
        }
    
        var indexPaths = [IndexPath]()
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            if indexPath.section == section {
                indexPaths.append(indexPath)
            }
        }
        
        return indexPaths
    }
    
    func visibleIndexPaths() -> [IndexPath] {
        return collectionView.indexPathsForVisibleItems
    }
    
    var visibleCells: [UICollectionViewCell] {
        return collectionView.visibleCells
    }
    
    var visibleItems: [ListDiffable] {
        var items: [ListDiffable] = []
        let indexPaths = visibleIndexPaths()
        for indexPath in indexPaths {
            let item = item(at: indexPath)
            items.append(item)
        }
        
        return items
    }
}

/// dataSource Helpers
extension TPCollectionViewAdapter {
    
    // MARK: - 从数据源获取数据
    func fetchSectionObjects() -> [ListDiffable] {
        let objects = dataSource?.sectionObjects(for: self) ?? []
        return objects
    }
    
    func fetchItems(for sectionObject: ListDiffable) -> [ListDiffable] {
        let items = dataSource?.adapter(self, itemsForSectionObject: sectionObject) ?? []
        return items
    }
    
}
