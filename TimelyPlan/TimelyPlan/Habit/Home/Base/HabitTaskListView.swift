//
//  HabitTaskListView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

protocol HabitTaskListViewDelegate: AnyObject {
    
    func groupsInHabitTaskListView(_ listView: HabitTaskListView) -> [HabitTaskGroup]?
    
    func habitTaskListView(_ listView: HabitTaskListView, classForCellAt indexPath: IndexPath) -> AnyClass?
    
    func habitTaskListView(_ listView: HabitTaskListView, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath)
    
    func habitTaskListView(_ listView: HabitTaskListView, classForHeaderInSection section: Int) -> AnyClass?
    
    func habitTaskListView(_ listView: HabitTaskListView, sizeForHeaderInSection section: Int) -> CGSize

    func habitTaskListView(_ listView: HabitTaskListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int)
}

extension HabitTaskListViewDelegate {
    
    func habitTaskListView(_ listView: HabitTaskListView, classForHeaderInSection section: Int) -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func habitTaskListView(_ listView: HabitTaskListView, sizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func habitTaskListView(_ listView: HabitTaskListView, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        
    }
}


class HabitTaskListView: TPCollectionWrapperView,
                                TPCollectionViewAdapterDataSource,
                                TPCollectionViewAdapterDelegate,
                                TPCollectionHeaderFooterViewDelegate {
    
    weak var delegate: HabitTaskListViewDelegate?
    
    var preferredItemHeight: CGFloat {
        get {
            return sectionLayout.preferredItemHeight
        }
        
        set {
            sectionLayout.preferredItemHeight = newValue
        }
    }
    
    /// 占位视图
    lazy var placeholderView: TPDefaultPlaceholderView = {
        let view = TPDefaultPlaceholderView()
        view.isBorderHidden = true
        view.titleColor = .lightGray
        return view
    }()
    
    /// 区块布局
    private(set) lazy var sectionLayout: TPCollectionSectionLayout = {
        let layout = TPCollectionSectionLayout()
        layout.edgeMargins = UIEdgeInsets(horizontal: 15.0, vertical: 10.0)
        layout.minimumItemsCountPerRow = 1
        layout.maximumItemsCountPerRow = 1
        layout.lineSpacing = 10.0
        layout.interitemSpacing = 10.0
        layout.preferredItemHeight = 80.0
        layout.preferredItemWidth = kHabitTaskListContentMaxWidth
        return layout
    }()
    
    var footerView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView.placeholderView = self.placeholderView
        self.collectionView.showsVerticalScrollIndicator = false
        self.adapter.footerSize = .zero
        self.adapter.cellStyle.cornerRadius = 20.0
        self.adapter.dataSource = self
        self.adapter.delegate = self
        self.adapter.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func sectionObject(at seciton: Int) -> ListDiffable {
        return adapter.object(at: seciton)
    }
    
    func item(at indexPath: IndexPath) -> ListDiffable {
        return adapter.item(at: indexPath)
    }
    
    func items(for seciton: Int) -> [ListDiffable] {
        let sectionObject = adapter.object(at: seciton)
        return adapter.items(for: sectionObject)
    }
    
    /// 聚焦显示任务
    func revealTask(_ task: HabitTask) {
        self.adapter.scrollToItem(task, at: .centeredVertically, animated: true) { _ in
            self.adapter.commitFocusAnimation(for: task)
        }
    }
    
    func performUpdate(with completion: ((Bool) -> Void)? = nil) {
        self.adapter.performUpdate(with: completion)
    }
    
    func reloadCell(forTask task: HabitTask, focusAnimated: Bool = false) {
        self.adapter.reloadCell(forItem: task, focusAnimated: focusAnimated)
    }
    
    func moveItem(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        self.adapter.moveItem(at: fromIndexPath, to: toIndexPath)
    }
    
    // MARK: - TPCollectionViewAdapterDataSource
    func sectionObjects(for adapter: TPCollectionViewAdapter) -> [ListDiffable]? {
        return delegate?.groupsInHabitTaskListView(self)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        let group = sectionObject as! HabitTaskGroup
        return group.tasks
    }
    
    // MARK: - TPCollectionViewAdapterDelegate
    func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if let delegate = delegate {
            return delegate.habitTaskListView(self, classForCellAt: indexPath)
        }
        
        return HabitTaskListBaseCell.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        delegate?.habitTaskListView(self, didDequeCell: cell, at: indexPath)
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
        
    }
    
    // MARK: - Header
    func adapter(_ adapter: TPCollectionViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if let delegate = delegate {
            return delegate.habitTaskListView(self, classForHeaderInSection: section)
        }
        
        return UICollectionReusableView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForHeaderInSection section: Int) -> CGSize {
        if let delegate = delegate {
            return delegate.habitTaskListView(self, sizeForHeaderInSection: section)
        }
        
        return .zero
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeHeader headerView: UICollectionReusableView, inSection section: Int) {
        if let delegate = delegate {
            delegate.habitTaskListView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    // MARK: - Footer
    
    /*
    func adapter(_ adapter: TPCollectionViewAdapter, classForFooterInSection section: Int) -> AnyClass? {
        return TPCollectionHeaderFooterView.self
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, sizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: .greatestFiniteMagnitude, height: 30.0)
    }
    
    func adapter(_ adapter: TPCollectionViewAdapter, didDequeFooter footerView: UICollectionReusableView, inSection section: Int) {
    }
     */
    
    // MARK: - TPCollectionHeaderFooterViewDelegate
    func layoutMarginsForHeaderFooterView(_ view: TPCollectionHeaderFooterView) -> UIEdgeInsets {
        return UIEdgeInsets(left: sectionLayout.sectionInset.left,
                            right: sectionLayout.sectionInset.right)
    }
}
