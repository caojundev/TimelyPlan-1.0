//
//  TPGroupCollectionView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/29.
//

import Foundation
import UIKit

protocol GroupRepresentable: ListDiffable {
    /// 分组内的条目
    var items: [ListDiffable]? { get }
}

protocol TPGroupCollectionViewDelegate: AnyObject {
    
    /// 获取单元格类
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass?
    
    /// 配置出队的单元格
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath)
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath)
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool
    
    /// 获取头部视图类
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForHeaderInSection section: Int) -> AnyClass?
    
    /// 获取头部视图尺寸
    func groupCollectionView(_ collectionView: TPGroupCollectionView, sizeForHeaderInSection section: Int) -> CGSize

    /// 配置出队的头部视图
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int)
}


extension TPGroupCollectionViewDelegate {
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return TPCollectionCell.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, classForHeaderInSection section: Int) -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, sizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func groupCollectionView(_ collectionView: TPGroupCollectionView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        
    }
    
    func groupCollectionView(_ collectionView: TPGroupCollectionView, didSelectItemAt indexPath: IndexPath) { }
}


class TPGroupCollectionView: TPCollectionWrapperView,
                             TPCollectionViewAdapterDataSource,
                             TPCollectionViewAdapterDelegate,
                                    TPCollectionHeaderFooterViewDelegate {
    
    var groups: [GroupRepresentable]?
    
    weak var delegate: TPGroupCollectionViewDelegate?
    
    /// 首选条目宽度和高度
    var preferredItemWidth: CGFloat {
        get {
            return sectionLayout.preferredItemWidth
        }
        
        set {
            sectionLayout.preferredItemWidth = newValue
        }
    }
    
    var preferredItemHeight: CGFloat {
        get {
            return sectionLayout.preferredItemHeight
        }
        
        set {
            sectionLayout.preferredItemHeight = newValue
        }
    }
    
    /// 区块布局
    private(set) lazy var sectionLayout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        layout.minimumItemsCountPerRow = 1
        layout.maximumItemsCountPerRow = 1
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        layout.preferredItemHeight = 80.0
        layout.preferredItemWidth = 560.0
        return layout
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.adapter.footerSize = .zero
        self.adapter.cellStyle.cornerRadius = 20.0
        self.adapter.dataSource = self
        self.adapter.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func allItems() -> [ListDiffable] {
        return adapter.allItems()
    }
    
    /// 获取指定区块的对象
    func sectionObject(at section: Int) -> ListDiffable {
        return adapter.object(at: section)
    }

    /// 获取指定区块的所有项
    func items(for section: Int) -> [ListDiffable] {
        let sectionObject = adapter.object(at: section)
        return adapter.items(for: sectionObject)
    }
    
    /// 获取指定索引路径的项
    func item(at indexPath: IndexPath) -> ListDiffable {
        return adapter.item(at: indexPath)
    }
    
    func cell(for item: ListDiffable) -> UICollectionViewCell? {
        return adapter.cellForItem(item)
    }

    var visibleCells: [UICollectionViewCell] {
        return adapter.visibleCells
    }
    
    /// 执行更新操作
    func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        self.adapter.performUpdate(with: completion)
    }
    
    /// 聚焦显示
    func revealItem(_ item: ListDiffable, autoScroll: Bool = true) {
        guard autoScroll else {
            self.adapter.commitFocusAnimation(for: item)
            return
        }
        
        self.adapter.scrollToItem(item, at: .centeredVertically, animated: true) { _ in
            self.adapter.commitFocusAnimation(for: item)
        }
    }

    /// 移动项的位置
    /// - Parameters:
    ///   - fromIndexPath: 源索引路径
    ///   - toIndexPath: 目标索引路径
    func moveItem(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        self.adapter.moveItem(at: fromIndexPath, to: toIndexPath)
    }
    
    func updateCheckmarks() {
        self.adapter.updateCheckmarks()
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return groups
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? GroupRepresentable else {
            return nil
        }
        
        return group.items
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if let delegate = delegate {
            return delegate.groupCollectionView(self, classForCellAt: indexPath)
        }
        
        return TPCollectionCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        delegate?.groupCollectionView(self, didDequeCell: cell, at: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sectionLayout.collectionViewSize = adapter.collectionViewSize()
        return sectionLayout.constraintCellSize ?? .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionLayout.sectionInset
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, interitemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionLayout.interitemSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, lineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionLayout.lineSpacing
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didSelectItemAt indexPath: IndexPath) {
        delegate?.groupCollectionView(self, didSelectItemAt: indexPath)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, shouldShowCheckmarkForItemAt indexPath: IndexPath) -> Bool {
        return delegate?.groupCollectionView(self, shouldShowCheckmarkForItemAt: indexPath) ?? false
    }
    
    // MARK: - Header Methods
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if let delegate = delegate {
            return delegate.groupCollectionView(self, classForHeaderInSection: section)
        }
        
        return UICollectionReusableView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        if let delegate = delegate {
            return delegate.groupCollectionView(self, sizeForHeaderInSection: section)
        }
        
        return .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let delegate = delegate {
            delegate.groupCollectionView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        if let delegate = delegate {
            delegate.groupCollectionView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    // MARK: - TPCollectionHeaderFooterViewDelegate
    func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        return UIEdgeInsets(left: sectionLayout.sectionInset.left,
                            right: sectionLayout.sectionInset.right)
    }
}
