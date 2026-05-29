//
//  TPGroupTableView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation
import UIKit

protocol TPGroupTableViewDelegate: AnyObject {
    
    /// 获取单元格类
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass?
    
    /// 获取头部视图尺寸
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    /// 配置出队的单元格
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath)
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath)
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool
    
    /// 获取头部视图类
    func groupTableView(_ tableView: TPGroupTableView, classForHeaderInSection section: Int) -> AnyClass?
    
    /// 获取头部视图尺寸
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat

    /// 配置出队的头部视图
    func groupTableView(_ tableView: TPGroupTableView, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int)
}


extension TPGroupTableViewDelegate {
    
    func groupTableView(_ tableView: TPGroupTableView, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return UITableViewCell.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didDequeCell cell: UITableViewCell, at indexPath: IndexPath) {
        
    }
    
    func groupTableView(_ tableView: TPGroupTableView, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func groupTableView(_ tableView: TPGroupTableView, classForHeaderInSection section: Int) -> AnyClass? {
        return UITableViewHeaderFooterView.self
    }
    
    func groupTableView(_ tableView: TPGroupTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func groupTableView(_ tableView: TPGroupTableView, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        
    }
    
    func groupTableView(_ tableView: TPGroupTableView, didSelectRowAt indexPath: IndexPath) { }
}


class TPGroupTableView: TPTableWrapperView,
                        TPTableViewAdapterDataSource,
                        TPTableViewAdapterDelegate {
    
    var groups: [GroupRepresentable]?
    
    weak var delegate: TPGroupTableViewDelegate?
    
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
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
    
    func cell(for item: ListDiffable) -> UITableViewCell? {
        return adapter.cellForItem(item)
    }

    var visibleCells: [UITableViewCell] {
        return adapter.visibleCells
    }
    
    func moveRow(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        self.adapter.moveRow(at: fromIndexPath, to: toIndexPath)
    }
    
    func updateCheckmarks() {
        self.adapter.updateCheckmarks()
    }
    
    // MARK: - TPTableViewAdapterDataSource
    func sectionObjects(for adapter: TPTableViewAdapter) -> [ListDiffable]? {
        return groups
    }
    
    func adapter(_ adapter: TPTableViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        guard let group = sectionObject as? GroupRepresentable else {
            return nil
        }
        
        return group.items
    }
    
    
    // MARK: - TPTableViewAdapterDelegate
    func adapter(_ adapter: TPTableViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        if let delegate = delegate {
            return delegate.groupTableView(self, classForCellAt: indexPath)
        }
        
        return UITableViewCell.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.groupTableView(self, didDequeCell: cell, at: indexPath)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegate?.groupTableView(self, heightForRowAt: indexPath) ?? 50.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didSelectRowAt indexPath: IndexPath) {
        delegate?.groupTableView(self, didSelectRowAt: indexPath)
    }
    
    func adapter(_ adapter: TPTableViewAdapter, shouldShowCheckmarkForRowAt indexPath: IndexPath) -> Bool {
        return delegate?.groupTableView(self, shouldShowCheckmarkForRowAt: indexPath) ?? false
    }
    
    func adapter(_ adapter: TPTableViewAdapter, classForHeaderInSection section: Int) -> AnyClass? {
        if let delegate = delegate {
            return delegate.groupTableView(self, classForHeaderInSection: section)
        }
        
        return TPDefaultInfoTableHeaderFooterView.self
    }
    
    func adapter(_ adapter: TPTableViewAdapter, heightForHeaderInSection section: Int) -> CGFloat {
        return delegate?.groupTableView(self, heightForHeaderInSection: section) ?? 0.0
    }
    
    func adapter(_ adapter: TPTableViewAdapter, didDequeHeader headerView: UITableViewHeaderFooterView, inSection section: Int) {
        if let headerView = headerView as? TPBaseTableHeaderFooterView {
            headerView.delegate = self
        }
        
        if let delegate = delegate {
            delegate.groupTableView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
    func adapter(_ adapter: TPTableViewAdapter, updateHeaderInSection section: Int) {
        guard let headerView = adapter.headerView(in: section) else {
            return
        }
        
        if let delegate = delegate {
            delegate.groupTableView(self, didDequeHeader: headerView, inSection: section)
        }
    }
    
}
